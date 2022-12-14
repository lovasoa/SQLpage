use crate::file_cache::AsyncFromStrWithState;
use crate::{AppState, FileCache, TEMPLATES_DIR};
use async_trait::async_trait;
use handlebars::{
    handlebars_helper, template::TemplateElement, Context, Handlebars, JsonValue, RenderError,
    Renderable, Template,
};
use include_dir::{include_dir, Dir};
use std::path::PathBuf;
use std::sync::Arc;

pub(crate) const DELAYED_CONTENTS: &str = "_delayed_contents";

pub struct SplitTemplate {
    pub before_list: Template,
    pub list_content: Template,
    pub after_list: Template,
}

pub fn split_template(mut original: Template) -> SplitTemplate {
    let mut elements_after = Vec::new();
    let mut mapping_after = Vec::new();
    let mut items_template = None;
    let found = original.elements.iter().position(is_template_list_item);
    if let Some(idx) = found {
        elements_after = original.elements.split_off(idx + 1);
        mapping_after = original.mapping.split_off(idx + 1);
        if let Some(TemplateElement::HelperBlock(tpl)) = original.elements.pop() {
            original.mapping.pop();
            items_template = tpl.template;
        }
    }
    let mut list_content = items_template.unwrap_or_default();
    list_content.name = original.name.clone();
    SplitTemplate {
        before_list: Template {
            name: original.name.clone(),
            elements: original.elements,
            mapping: original.mapping,
        },
        list_content,
        after_list: Template {
            name: original.name,
            elements: elements_after,
            mapping: mapping_after,
        },
    }
}

#[async_trait(? Send)]
impl AsyncFromStrWithState for SplitTemplate {
    async fn from_str_with_state(_app_state: &AppState, source: &str) -> anyhow::Result<Self> {
        let tpl = Template::compile(source)?;
        Ok(split_template(tpl))
    }
}

fn is_template_list_item(element: &TemplateElement) -> bool {
    use handlebars::template::Parameter;
    use Parameter::Name;
    matches!(element,
                    TemplateElement::HelperBlock(tpl)
                        if matches!(&tpl.name, Name(name) if name == "each_row"))
}

#[allow(clippy::module_name_repetitions)]
pub struct AllTemplates {
    pub handlebars: Handlebars<'static>,
    split_templates: FileCache<SplitTemplate>,
}

fn with_each_block<'a, 'reg, 'rc>(
    rc: &'a mut handlebars::RenderContext<'reg, 'rc>,
    mut action: impl FnMut(&mut handlebars::BlockContext<'rc>, bool) -> Result<(), RenderError>,
) -> Result<(), RenderError> {
    let mut blks = Vec::new();
    while let Some(mut top) = rc.block_mut().map(std::mem::take) {
        rc.pop_block();
        action(&mut top, rc.block().is_none())?;
        blks.push(top);
    }
    while let Some(blk) = blks.pop() {
        rc.push_block(blk);
    }
    Ok(())
}

fn delay_helper<'reg, 'rc>(
    h: &handlebars::Helper<'rc>,
    r: &'reg Handlebars<'reg>,
    ctx: &'rc Context,
    rc: &mut handlebars::RenderContext<'reg, 'rc>,
    _out: &mut dyn handlebars::Output,
) -> handlebars::HelperResult {
    let inner = h
        .template()
        .ok_or_else(|| RenderError::new("missing delayed contents"))?;
    let mut str_out = handlebars::StringOutput::new();
    inner.render(r, ctx, rc, &mut str_out)?;
    let mut delayed_render = str_out.into_string()?;
    with_each_block(rc, |block, is_last| {
        if is_last {
            let old_delayed_render = block
                .get_local_var(DELAYED_CONTENTS)
                .and_then(JsonValue::as_str)
                .unwrap_or_default();
            delayed_render += old_delayed_render;
            let contents = JsonValue::String(std::mem::take(&mut delayed_render));
            block.set_local_var(DELAYED_CONTENTS, contents);
        }
        Ok(())
    })?;
    Ok(())
}

fn flush_delayed_helper<'reg, 'rc>(
    _h: &handlebars::Helper<'rc>,
    _r: &'reg Handlebars<'reg>,
    _ctx: &'rc Context,
    rc: &mut handlebars::RenderContext<'reg, 'rc>,
    writer: &mut dyn handlebars::Output,
) -> handlebars::HelperResult {
    with_each_block(rc, |block_context, _last| {
        let delayed = block_context
            .get_local_var(DELAYED_CONTENTS)
            .and_then(JsonValue::as_str)
            .filter(|s| !s.is_empty());
        if let Some(contents) = delayed {
            writer.write(contents)?;
            block_context.set_local_var(DELAYED_CONTENTS, JsonValue::Null);
        }
        Ok(())
    })
}

const STATIC_TEMPLATES: Dir = include_dir!("$CARGO_MANIFEST_DIR/sqlpage/templates");

impl AllTemplates {
    pub fn init() -> anyhow::Result<Self> {
        let mut handlebars = Handlebars::new();
        handlebars_helper!(stringify: |v: Json| v.to_string());
        handlebars.register_helper("stringify", Box::new(stringify));
        handlebars_helper!(default: |a: Json, b:Json| if a.is_null() {b} else {a}.clone());
        handlebars.register_helper("default", Box::new(default));
        handlebars_helper!(entries: |v: Json | match v {
            serde_json::value::Value::Object(map) =>
                map.into_iter()
                    .map(|(k, v)| serde_json::json!({"key": k, "value": v}))
                    .collect(),
            serde_json::value::Value::Array(values) =>
                values.iter()
                    .enumerate()
                    .map(|(k, v)| serde_json::json!({"key": k, "value": v}))
                    .collect(),
            _ => vec![]
        });
        handlebars.register_helper("entries", Box::new(entries));
        handlebars.register_helper("delay", Box::new(delay_helper));
        handlebars.register_helper("flush_delayed", Box::new(flush_delayed_helper));
        let mut this = Self {
            handlebars,
            split_templates: FileCache::new(),
        };
        this.preregister_static_templates()?;
        Ok(this)
    }

    /// Embeds pre-defined templates directly in the binary in release mode
    pub fn preregister_static_templates(&mut self) -> anyhow::Result<()> {
        for file in STATIC_TEMPLATES.files() {
            let mut path = PathBuf::from(TEMPLATES_DIR);
            path.push(file.path());
            let source = String::from_utf8_lossy(file.contents());
            let tpl = Template::compile(&source)?;
            let split_template = split_template(tpl);
            self.split_templates.add_static(path, split_template);
        }
        Ok(())
    }

    pub async fn get_template(
        &self,
        app_state: &AppState,
        name: &str,
    ) -> anyhow::Result<Arc<SplitTemplate>> {
        use anyhow::Context;
        let mut path: PathBuf =
            PathBuf::with_capacity(TEMPLATES_DIR.len() + name.len() + ".handlebars".len() + 2);
        path.push(TEMPLATES_DIR);
        path.push(name);
        path.set_extension("handlebars");
        self.split_templates
            .get(app_state, &path)
            .await
            .with_context(|| format!("The component '{name}' was not found."))
    }
}

#[test]
fn test_split_template() {
    let template = Template::compile(
        "Hello {{name}} ! \
        {{#each_row}}<li>{{this}}</li>{{/each_row}}\
        end",
    )
    .unwrap();
    let split = split_template(template);
    assert_eq!(
        split.before_list.elements,
        Template::compile("Hello {{name}} ! ").unwrap().elements
    );
    assert_eq!(
        split.list_content.elements,
        Template::compile("<li>{{this}}</li>").unwrap().elements
    );
    assert_eq!(
        split.after_list.elements,
        Template::compile("end").unwrap().elements
    );
}
