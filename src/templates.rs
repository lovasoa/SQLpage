use crate::file_cache::AsyncFromStrWithState;
use crate::template_helpers::register_all_helpers;
use crate::{AppState, FileCache, TEMPLATES_DIR};
use async_trait::async_trait;
use handlebars::{template::TemplateElement, Handlebars, Template};
use include_dir::{include_dir, Dir};
use std::path::PathBuf;
use std::sync::Arc;

pub struct SplitTemplate {
    pub before_list: Template,
    pub list_content: Template,
    pub after_list: Template,
}

impl SplitTemplate {
    #[must_use]
    pub fn name(&self) -> Option<&str> {
        self.before_list.name.as_deref()
    }
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

const STATIC_TEMPLATES: Dir = include_dir!("$CARGO_MANIFEST_DIR/sqlpage/templates");

impl AllTemplates {
    pub fn init() -> anyhow::Result<Self> {
        let mut handlebars = Handlebars::new();
        register_all_helpers(&mut handlebars);
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
            let name = file
                .path()
                .file_stem()
                .unwrap()
                .to_string_lossy()
                .to_string();
            let source = String::from_utf8_lossy(file.contents());
            let tpl = Template::compile_with_name(&source, name)?;
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
            PathBuf::with_capacity(TEMPLATES_DIR.len() + 1 + name.len() + ".handlebars".len());
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
