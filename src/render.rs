use crate::templates::SplitTemplate;
use crate::AppState;
use actix_web::http::StatusCode;
use actix_web::HttpResponseBuilder;
use anyhow::{format_err, Context as AnyhowContext};
use async_recursion::async_recursion;
use handlebars::{BlockContext, Context, JsonValue, RenderError, Renderable};
use serde::Serialize;
use serde_json::{json, Value};
use std::borrow::Cow;
use std::sync::Arc;

pub enum PageContext<W: std::io::Write> {
    Header(HeaderContext<W>),
    Body {
        http_response: HttpResponseBuilder,
        renderer: RenderContext<W>,
    },
}

/// Handles the first SQL statements, before the headers have been sent to
pub struct HeaderContext<W: std::io::Write> {
    app_state: Arc<AppState>,
    pub writer: W,
    response: HttpResponseBuilder,
}

impl<W: std::io::Write> HeaderContext<W> {
    pub fn new(app_state: Arc<AppState>, writer: W) -> Self {
        let mut response = HttpResponseBuilder::new(StatusCode::OK);
        response.content_type("text/html; charset=utf-8");
        Self {
            app_state,
            writer,
            response,
        }
    }
    pub async fn handle_row(self, data: JsonValue) -> anyhow::Result<PageContext<W>> {
        log::debug!("Handling header row: {data}");
        match get_object_str(&data, "component") {
            Some("http_header") => self.add_http_header(&data).map(PageContext::Header),
            _ => self.start_body(data).await,
        }
    }

    fn add_http_header(mut self, data: &JsonValue) -> anyhow::Result<Self> {
        let obj = data.as_object().with_context(|| "expected object")?;
        for (name, value) in obj {
            if name == "component" {
                continue;
            }
            let value_str = value
                .as_str()
                .with_context(|| "http header values must be strings")?;
            self.response.insert_header((name.as_str(), value_str));
        }
        Ok(self)
    }

    async fn start_body(self, data: JsonValue) -> anyhow::Result<PageContext<W>> {
        let renderer = RenderContext::new(self.app_state, self.writer, data).await?;
        let http_response = self.response;
        Ok(PageContext::Body {
            renderer,
            http_response,
        })
    }
}

fn get_object_str<'a>(json: &'a JsonValue, key: &str) -> Option<&'a str> {
    json.as_object()
        .and_then(|obj| obj.get(key))
        .and_then(JsonValue::as_str)
}

#[allow(clippy::module_name_repetitions)]
pub struct RenderContext<W: std::io::Write> {
    app_state: Arc<AppState>,
    pub writer: W,
    current_component: SplitTemplateRenderer,
    shell_renderer: SplitTemplateRenderer,
    recursion_depth: usize,
    current_statement: usize,
}

const DEFAULT_COMPONENT: &str = "default";
const SHELL_COMPONENT: &str = "shell";
const MAX_RECURSION_DEPTH: usize = 256;

impl<W: std::io::Write> RenderContext<W> {
    pub async fn new(
        app_state: Arc<AppState>,
        mut writer: W,
        mut initial_row: JsonValue,
    ) -> anyhow::Result<RenderContext<W>> {
        log::debug!("Creating the shell component for the page");
        let mut shell_renderer = Self::create_renderer(SHELL_COMPONENT, Arc::clone(&app_state))
            .await
            .with_context(|| "The shell component should always exist")?;

        let mut initial_component = get_object_str(&initial_row, "component");
        let shell_properties;
        if initial_component == Some(SHELL_COMPONENT) {
            shell_properties = initial_row.take();
            initial_component = None;
        } else {
            shell_properties = json!(null);
        }
        log::debug!("Rendering the shell with properties: {shell_properties}");
        shell_renderer.render_start(&mut writer, shell_properties)?;

        let current_component_name = initial_component.unwrap_or(DEFAULT_COMPONENT);
        log::debug!("Creating the first component in the page: '{current_component_name}'");
        let current_component = Self::create_renderer(current_component_name, Arc::clone(&app_state))
            .await
            .with_context(|| format!("Unable to open the rendering context because opening the {current_component_name} component failed"))?;

        Ok(RenderContext {
            app_state,
            writer,
            current_component,
            shell_renderer,
            recursion_depth: 0,
            current_statement: 1,
        })
    }

    #[async_recursion(? Send)]
    pub async fn handle_row(&mut self, data: &JsonValue) -> anyhow::Result<()> {
        log::debug!(
            "<- Processing database row: {}",
            serde_json::to_string(&data).unwrap_or_else(|e| e.to_string())
        );
        let new_component = get_object_str(data, "component");
        let current_component = SplitTemplateRenderer::name(&self.current_component);
        match (current_component, new_component) {
            (_current_component, Some("dynamic")) => {
                self.render_dynamic(data).await?;
            }
            (_current_component, Some(new_component)) => {
                self.open_component_with_data(new_component, &data).await?;
            }
            (_, _) => {
                self.render_current_template_with_data(&data)?;
            }
        }
        Ok(())
    }

    async fn render_dynamic(&mut self, data: &Value) -> anyhow::Result<()> {
        anyhow::ensure!(
            self.recursion_depth <= MAX_RECURSION_DEPTH,
            "Maximum recursion depth exceeded in the dynamic component."
        );
        let properties: Vec<Cow<JsonValue>> = data
            .get("properties")
            .and_then(|props| match props {
                Value::String(s) => match serde_json::from_str::<JsonValue>(s).ok()? {
                    Value::Array(values) => Some(values.into_iter().map(Cow::Owned).collect()),
                    obj @ Value::Object(_) => Some(vec![Cow::Owned(obj)]),
                    _ => None,
                },
                obj @ Value::Object(_) => Some(vec![Cow::Borrowed(obj)]),
                _ => None,
            })
            .context(
                "The dynamic component requires a parameter called 'parameters' that is a json ",
            )?;
        for p in properties {
            self.recursion_depth += 1;
            let res = self.handle_row(&p).await;
            self.recursion_depth -= 1;
            res?;
        }
        Ok(())
    }

    #[allow(clippy::unused_async)]
    pub async fn finish_query(&mut self) -> anyhow::Result<()> {
        log::debug!("-> Query {} finished", self.current_statement);
        self.current_statement += 1;
        Ok(())
    }

    /// Handles the rendering of an error.
    /// Returns whether the error is irrecoverable and the rendering must stop
    pub async fn handle_error(&mut self, error: &anyhow::Error) -> anyhow::Result<()> {
        log::warn!("SQL error: {:?}", error);
        self.close_component()?;
        let saved_component = self.open_component("error").await?;
        let description = error.to_string();
        let mut backtrace = vec![];
        let mut source = error.source();
        while let Some(s) = source {
            backtrace.push(format!("{s}"));
            source = s.source();
        }
        self.render_current_template_with_data(&json!({
            "query_number": self.current_statement,
            "description": description,
            "backtrace": backtrace
        }))?;
        self.close_component()?;
        self.current_component = saved_component;
        Ok(())
    }

    pub async fn handle_result<R>(&mut self, result: &anyhow::Result<R>) -> anyhow::Result<()> {
        if let Err(error) = result {
            self.handle_error(error).await
        } else {
            Ok(())
        }
    }

    pub async fn handle_result_and_log<R>(&mut self, result: &anyhow::Result<R>) {
        if let Err(e) = self.handle_result(result).await {
            log::error!("{}", e);
        }
    }

    fn render_current_template_with_data<T: Serialize>(&mut self, data: &T) -> anyhow::Result<()> {
        self.current_component
            .render_item(&mut self.writer, json!(data))?;
        self.shell_renderer
            .render_item(&mut self.writer, JsonValue::Null)?;
        Ok(())
    }

    async fn open_component(&mut self, component: &str) -> anyhow::Result<SplitTemplateRenderer> {
        self.open_component_with_data(component, &json!(null)).await
    }

    async fn create_renderer(
        component: &str,
        app_state: Arc<AppState>,
    ) -> anyhow::Result<SplitTemplateRenderer> {
        let split_template = app_state
            .all_templates
            .get_template(&app_state, component)
            .await?;
        Ok(SplitTemplateRenderer::new(split_template, app_state))
    }

    /// Set a new current component and return the old one
    async fn set_current_component(
        &mut self,
        component: &str,
    ) -> anyhow::Result<SplitTemplateRenderer> {
        let new_component = Self::create_renderer(component, Arc::clone(&self.app_state)).await?;
        Ok(std::mem::replace(
            &mut self.current_component,
            new_component,
        ))
    }

    async fn open_component_with_data<T: Serialize>(
        &mut self,
        component: &str,
        data: &T,
    ) -> anyhow::Result<SplitTemplateRenderer> {
        self.close_component()?;
        let old_component = self.set_current_component(component).await?;
        self.current_component
            .render_start(&mut self.writer, json!(data))?;
        Ok(old_component)
    }

    fn close_component(&mut self) -> anyhow::Result<()> {
        self.current_component.render_end(&mut self.writer)?;
        Ok(())
    }

    pub async fn close(mut self) -> W {
        let res = self
            .current_component
            .render_end(&mut self.writer)
            .map_err(|e| format_err!("Unable to render the component closing: {e}"));
        self.handle_result_and_log(&res).await;

        let res = self
            .shell_renderer
            .render_end(&mut self.writer)
            .map_err(|e| format_err!("Unable to render the shell closing: {e}"));
        self.handle_result_and_log(&res).await;
        self.writer
    }
}

struct HandlebarWriterOutput<W: std::io::Write>(W);

impl<W: std::io::Write> handlebars::Output for HandlebarWriterOutput<W> {
    fn write(&mut self, seg: &str) -> std::io::Result<()> {
        std::io::Write::write_all(&mut self.0, seg.as_bytes())
    }
}

pub struct SplitTemplateRenderer {
    split_template: Arc<SplitTemplate>,
    local_vars: Option<handlebars::LocalVars>,
    ctx: Context,
    app_state: Arc<AppState>,
    row_index: usize,
}

impl SplitTemplateRenderer {
    fn new(split_template: Arc<SplitTemplate>, app_state: Arc<AppState>) -> Self {
        Self {
            split_template,
            local_vars: None,
            app_state,
            row_index: 0,
            ctx: Context::null(),
        }
    }
    fn name(&self) -> &str {
        self.split_template
            .list_content
            .name
            .as_deref()
            .unwrap_or_default()
    }

    fn render_start<W: std::io::Write>(
        &mut self,
        writer: W,
        data: JsonValue,
    ) -> Result<(), RenderError> {
        log::trace!("Starting rendering of a new page with the following page-level data: {data}");
        let mut render_context = handlebars::RenderContext::new(None);
        *self.ctx.data_mut() = data;
        let mut output = HandlebarWriterOutput(writer);
        self.split_template.before_list.render(
            &self.app_state.all_templates.handlebars,
            &self.ctx,
            &mut render_context,
            &mut output,
        )?;
        self.local_vars = render_context
            .block_mut()
            .map(|blk| std::mem::take(blk.local_variables_mut()));
        self.row_index = 0;
        Ok(())
    }

    fn render_item<W: std::io::Write>(
        &mut self,
        writer: W,
        data: JsonValue,
    ) -> Result<(), RenderError> {
        log::trace!("Rendering a new item in the page: {data:?}");
        if let Some(local_vars) = self.local_vars.take() {
            let mut render_context = handlebars::RenderContext::new(None);
            let blk = render_context
                .block_mut()
                .expect("context created without block");
            *blk.local_variables_mut() = local_vars;
            let mut blk = BlockContext::new();
            blk.set_base_value(data);
            blk.set_local_var("row_index", JsonValue::Number(self.row_index.into()));
            render_context.push_block(blk);
            let mut output = HandlebarWriterOutput(writer);
            self.split_template.list_content.render(
                &self.app_state.all_templates.handlebars,
                &self.ctx,
                &mut render_context,
                &mut output,
            )?;
            render_context.pop_block();
            self.local_vars = render_context
                .block_mut()
                .map(|blk| std::mem::take(blk.local_variables_mut()));
            self.row_index += 1;
        }
        Ok(())
    }

    fn render_end<W: std::io::Write>(&mut self, writer: W) -> Result<(), RenderError> {
        log::trace!("Closing the current page");
        if let Some(local_vars) = self.local_vars.take() {
            let mut render_context = handlebars::RenderContext::new(None);
            *render_context
                .block_mut()
                .expect("ctx created without block")
                .local_variables_mut() = local_vars;
            let mut output = HandlebarWriterOutput(writer);
            self.split_template.after_list.render(
                &self.app_state.all_templates.handlebars,
                &self.ctx,
                &mut render_context,
                &mut output,
            )?;
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::templates::split_template;
    use handlebars::Template;

    #[actix_web::test]
    async fn test_split_template_render() -> anyhow::Result<()> {
        let template = Template::compile(
            "Hello {{name}} !\
        {{#each_row}} ({{x}} : {{../name}}) {{/each_row}}\
        Goodbye {{name}}",
        )?;
        let split = split_template(template);
        let mut output = Vec::new();
        let app_state = Arc::new(AppState::init().unwrap());
        let mut rdr = SplitTemplateRenderer::new(Arc::new(split), app_state);
        rdr.render_start(&mut output, json!({"name": "SQL"}))?;
        rdr.render_item(&mut output, json!({"x": 1}))?;
        rdr.render_item(&mut output, json!({"x": 2}))?;
        rdr.render_end(&mut output)?;
        assert_eq!(
            String::from_utf8_lossy(&output),
            "Hello SQL ! (1 : SQL)  (2 : SQL) Goodbye SQL"
        );
        Ok(())
    }

    #[actix_web::test]
    async fn test_delayed() -> anyhow::Result<()> {
        let template = Template::compile(
            "{{#each_row}}<b> {{x}} {{#delay}} {{x}} </b>{{/delay}}{{/each_row}}{{flush_delayed}}",
        )?;
        let split = split_template(template);
        let mut output = Vec::new();
        let app_state = Arc::new(AppState::init().unwrap());
        let mut rdr = SplitTemplateRenderer::new(Arc::new(split), app_state);
        rdr.render_start(&mut output, json!(null))?;
        rdr.render_item(&mut output, json!({"x": 1}))?;
        rdr.render_item(&mut output, json!({"x": 2}))?;
        rdr.render_end(&mut output)?;
        assert_eq!(
            String::from_utf8_lossy(&output),
            "<b> 1 <b> 2  2 </b> 1 </b>"
        );
        Ok(())
    }
}
