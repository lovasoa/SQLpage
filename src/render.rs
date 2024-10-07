use crate::templates::SplitTemplate;
use crate::webserver::http::RequestContext;
use crate::webserver::ErrorWithStatus;
use crate::AppState;
use actix_web::cookie::time::format_description::well_known::Rfc3339;
use actix_web::cookie::time::OffsetDateTime;
use actix_web::http::{header, StatusCode};
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};
use anyhow::{bail, format_err, Context as AnyhowContext};
use async_recursion::async_recursion;
use awc::cookie::time::Duration;
use handlebars::{BlockContext, Context, JsonValue, RenderError, Renderable};
use serde::Serialize;
use serde_json::{json, Value};
use std::borrow::Cow;
use std::sync::Arc;

pub enum PageContext<W: std::io::Write> {
    /// Indicates that we should stay in the header context
    Header(HeaderContext<W>),

    /// Indicates that we should start rendering the body
    Body {
        http_response: HttpResponseBuilder,
        renderer: RenderContext<W>,
    },

    /// The response is ready, and should be sent as is. No further statements should be executed
    Close(HttpResponse),
}

/// Handles the first SQL statements, before the headers have been sent to
pub struct HeaderContext<W: std::io::Write> {
    app_state: Arc<AppState>,
    request_context: RequestContext,
    pub writer: W,
    response: HttpResponseBuilder,
    has_status: bool,
}

impl<'a, W: std::io::Write> HeaderContext<W> {
    pub fn new(app_state: Arc<AppState>, request_context: RequestContext, writer: W) -> Self {
        let mut response = HttpResponseBuilder::new(StatusCode::OK);
        response.content_type("text/html; charset=utf-8");
        if app_state.config.content_security_policy.is_none() {
            response.insert_header(&request_context.content_security_policy);
        }
        Self {
            app_state,
            request_context,
            writer,
            response,
            has_status: false,
        }
    }
    pub async fn handle_row(self, data: JsonValue) -> anyhow::Result<PageContext<W>> {
        log::debug!("Handling header row: {data}");
        match get_object_str(&data, "component") {
            Some("status_code") => self.status_code(&data).map(PageContext::Header),
            Some("http_header") => self.add_http_header(&data).map(PageContext::Header),
            Some("redirect") => self.redirect(&data).map(PageContext::Close),
            Some("json") => self.json(&data).map(PageContext::Close),
            Some("csv_attachment") => self.csv_attachment(data).await,
            Some("cookie") => self.add_cookie(&data).map(PageContext::Header),
            Some("authentication") => self.authentication(data).await,
            _ => self.start_body(data).await,
        }
    }

    pub async fn handle_error(self, err: anyhow::Error) -> anyhow::Result<PageContext<W>> {
        if self.app_state.config.environment.is_prod() {
            return Err(err);
        }
        log::debug!("Handling header error: {err}");
        let data = json!({
            "component": "error",
            "description": err.to_string(),
            "backtrace": get_backtrace(&err),
        });
        self.start_body(data).await
    }

    fn status_code(mut self, data: &JsonValue) -> anyhow::Result<Self> {
        let status_code = data
            .as_object()
            .and_then(|m| m.get("status"))
            .with_context(|| "status_code component requires a status")?
            .as_u64()
            .with_context(|| "status must be a number")?;
        let code = u16::try_from(status_code)
            .with_context(|| format!("status must be a number between 0 and {}", u16::MAX))?;
        self.response.status(StatusCode::from_u16(code)?);
        self.has_status = true;
        Ok(self)
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
            if name.eq_ignore_ascii_case("location") && !self.has_status {
                self.response.status(StatusCode::FOUND);
                self.has_status = true;
            }
            self.response.insert_header((name.as_str(), value_str));
        }
        Ok(self)
    }

    fn add_cookie(mut self, data: &JsonValue) -> anyhow::Result<Self> {
        let obj = data.as_object().with_context(|| "expected object")?;
        let name = obj
            .get("name")
            .and_then(JsonValue::as_str)
            .with_context(|| "cookie name must be a string")?;
        let mut cookie = actix_web::cookie::Cookie::named(name);

        let path = obj.get("path").and_then(JsonValue::as_str);
        if let Some(path) = path {
            cookie.set_path(path);
        } else {
            cookie.set_path("/");
        }
        let domain = obj.get("domain").and_then(JsonValue::as_str);
        if let Some(domain) = domain {
            cookie.set_domain(domain);
        }

        let remove = obj.get("remove");
        if remove == Some(&json!(true)) || remove == Some(&json!(1)) {
            cookie.make_removal();
            self.response.cookie(cookie);
            log::trace!("Removing cookie {}", name);
            return Ok(self);
        }

        let value = obj
            .get("value")
            .and_then(JsonValue::as_str)
            .with_context(|| "The 'value' property of the cookie component is required (unless 'remove' is set) and must be a string.")?;
        cookie.set_value(value);
        let http_only = obj.get("http_only");
        cookie.set_http_only(http_only != Some(&json!(false)) && http_only != Some(&json!(0)));
        let same_site = obj.get("same_site").and_then(Value::as_str);
        cookie.set_same_site(match same_site {
            Some("none") => actix_web::cookie::SameSite::None,
            Some("lax") => actix_web::cookie::SameSite::Lax,
            None | Some("strict") => actix_web::cookie::SameSite::Strict, // strict by default
            Some(other) => bail!("Cookie: invalid value for same_site: {}", other),
        });
        let secure = obj.get("secure");
        cookie.set_secure(secure != Some(&json!(false)) && secure != Some(&json!(0)));
        if let Some(max_age_json) = obj.get("max_age") {
            let seconds = max_age_json
                .as_i64()
                .ok_or_else(|| anyhow::anyhow!("max_age must be a number, not {max_age_json}"))?;
            cookie.set_max_age(Duration::seconds(seconds));
        }
        let expires = obj.get("expires");
        if let Some(expires) = expires {
            cookie.set_expires(actix_web::cookie::Expiration::DateTime(match expires {
                JsonValue::String(s) => OffsetDateTime::parse(s, &Rfc3339)?,
                JsonValue::Number(n) => OffsetDateTime::from_unix_timestamp(
                    n.as_i64().with_context(|| "expires must be a timestamp")?,
                )?,
                _ => bail!("expires must be a string or a number"),
            }));
        }
        log::trace!("Setting cookie {}", cookie);
        self.response
            .append_header((header::SET_COOKIE, cookie.encoded().to_string()));
        Ok(self)
    }

    fn redirect(mut self, data: &JsonValue) -> anyhow::Result<HttpResponse> {
        self.response.status(StatusCode::FOUND);
        self.has_status = true;
        let link = get_object_str(data, "link")
            .with_context(|| "The redirect component requires a 'link' property")?;
        self.response.insert_header((header::LOCATION, link));
        let response = self.response.body(());
        Ok(response)
    }

    /// Answers to the HTTP request with a single json object
    fn json(mut self, data: &JsonValue) -> anyhow::Result<HttpResponse> {
        let contents = data
            .get("contents")
            .with_context(|| "Missing 'contents' property for the json component")?;
        let json_response = if let Some(s) = contents.as_str() {
            s.as_bytes().to_owned()
        } else {
            serde_json::to_vec(contents)?
        };
        self.response
            .insert_header((header::CONTENT_TYPE, "application/json"));
        Ok(self.response.body(json_response))
    }

    async fn csv_attachment(mut self, data: JsonValue) -> anyhow::Result<PageContext<W>> {
        let filename = data
            .get("filename")
            .and_then(JsonValue::as_str)
            .unwrap_or("output.csv");

        self.response
            .insert_header((header::CONTENT_TYPE, "text/csv"))
            .insert_header((
                header::CONTENT_DISPOSITION,
                format!("attachment; filename=\"{}\"", filename),
            ));

        self.request_context.is_embedded = true;
        let page_content = self.start_body(data).await?;

        Ok(page_content)
    }

    async fn authentication(mut self, mut data: JsonValue) -> anyhow::Result<PageContext<W>> {
        let password_hash = take_object_str(&mut data, "password_hash");
        let password = take_object_str(&mut data, "password");
        if let (Some(password), Some(password_hash)) = (password, password_hash) {
            log::debug!("Authentication with password_hash = {:?}", password_hash);
            match verify_password_async(password_hash, password).await? {
                Ok(()) => return Ok(PageContext::Header(self)),
                Err(e) => log::info!("Password didn't match: {}", e),
            }
        }
        log::debug!("Authentication failed");
        // The authentication failed
        let http_response: HttpResponse = if let Some(link) = get_object_str(&data, "link") {
            self.response
                .status(StatusCode::FOUND)
                .insert_header((header::LOCATION, link))
                .body(
                    "Sorry, but you are not authorized to access this page. \
                    Redirecting to the login page...",
                )
        } else {
            ErrorWithStatus {
                status: StatusCode::UNAUTHORIZED,
            }
            .error_response()
        };
        self.has_status = true;
        Ok(PageContext::Close(http_response))
    }

    async fn start_body(self, data: JsonValue) -> anyhow::Result<PageContext<W>> {
        let renderer = RenderContext::new(self.app_state, self.request_context, self.writer, data)
            .await
            .with_context(|| "Failed to create a render context from the header context.")?;
        let http_response = self.response;
        Ok(PageContext::Body {
            renderer,
            http_response,
        })
    }

    pub fn close(mut self) -> HttpResponse {
        self.response.finish()
    }
}

async fn verify_password_async(
    password_hash: String,
    password: String,
) -> Result<Result<(), password_hash::Error>, anyhow::Error> {
    tokio::task::spawn_blocking(move || {
        let hash = password_hash::PasswordHash::new(&password_hash)
            .map_err(|e| anyhow::anyhow!("invalid value for the password_hash property: {}", e))?;
        let phfs = &[&argon2::Argon2::default() as &dyn password_hash::PasswordVerifier];
        Ok(hash.verify_password(phfs, password))
    })
    .await?
}

fn get_backtrace(error: &anyhow::Error) -> Vec<String> {
    let mut backtrace = vec![];
    let mut source = error.source();
    while let Some(s) = source {
        backtrace.push(format!("{s}"));
        source = s.source();
    }
    backtrace
}

fn get_object_str<'a>(json: &'a JsonValue, key: &str) -> Option<&'a str> {
    json.as_object()
        .and_then(|obj| obj.get(key))
        .and_then(JsonValue::as_str)
}

fn take_object_str(json: &mut JsonValue, key: &str) -> Option<String> {
    match json.get_mut(key)?.take() {
        JsonValue::String(s) => Some(s),
        _ => None,
    }
}

#[allow(clippy::module_name_repetitions)]
pub struct RenderContext<W: std::io::Write> {
    app_state: Arc<AppState>,
    pub writer: W,
    current_component: Option<SplitTemplateRenderer>,
    shell_renderer: SplitTemplateRenderer,
    current_statement: usize,
    request_context: RequestContext,
}

const DEFAULT_COMPONENT: &str = "table";
const PAGE_SHELL_COMPONENT: &str = "shell";
const FRAGMENT_SHELL_COMPONENT: &str = "shell-empty";

impl<W: std::io::Write> RenderContext<W> {
    pub async fn new(
        app_state: Arc<AppState>,
        request_context: RequestContext,
        mut writer: W,
        initial_row: JsonValue,
    ) -> anyhow::Result<RenderContext<W>> {
        log::debug!("Creating the shell component for the page");

        let mut initial_rows = vec![Cow::Borrowed(&initial_row)];

        if !initial_rows
            .first()
            .and_then(|c| get_object_str(c, "component"))
            .is_some_and(Self::is_shell_component)
        {
            let default_shell = if request_context.is_embedded {
                FRAGMENT_SHELL_COMPONENT
            } else {
                PAGE_SHELL_COMPONENT
            };
            let added_row = json!({"component": default_shell});
            log::trace!(
                "No shell component found in the first row. Adding the default shell: {added_row}"
            );
            initial_rows.insert(0, Cow::Owned(added_row));
        }
        let mut rows_iter = initial_rows.into_iter().map(Cow::into_owned);

        let shell_row = rows_iter
            .next()
            .expect("shell row should exist at this point");
        let mut shell_renderer = Self::create_renderer(
            get_object_str(&shell_row, "component").expect("shell should exist"),
            Arc::clone(&app_state),
            0,
            request_context.content_security_policy.nonce,
        )
        .await
        .with_context(|| "The shell component should always exist")?;
        log::debug!("Rendering the shell with properties: {shell_row}");
        shell_renderer.render_start(&mut writer, shell_row)?;

        let mut initial_context = RenderContext {
            app_state,
            writer,
            current_component: None,
            shell_renderer,
            current_statement: 1,
            request_context,
        };

        for row in rows_iter {
            initial_context.handle_row(&row).await?;
        }

        Ok(initial_context)
    }

    fn is_shell_component(component: &str) -> bool {
        component.starts_with(PAGE_SHELL_COMPONENT)
    }

    #[async_recursion(? Send)]
    pub async fn handle_row(&mut self, data: &JsonValue) -> anyhow::Result<()> {
        log::debug!(
            "<- Rendering properties: {}",
            serde_json::to_string(&data).unwrap_or_else(|e| e.to_string())
        );
        let new_component = get_object_str(data, "component");
        let current_component = self
            .current_component
            .as_ref()
            .map(SplitTemplateRenderer::name);
        match (current_component, new_component) {
            (
                _,
                Some(
                    component_name @ ("status_code" | "http_header" | "redirect" | "json"
                    | "cookie" | "authentication"),
                ),
            ) => {
                bail!("The {component_name} component cannot be used after data has already been sent to the client's browser. \
                This component must be used before any other component. \
                To fix this, either move the call to the '{component_name}' component to the top of the SQL file, or create a new SQL file where '{component_name}' is the first component.");
            }
            (_, Some(c)) if Self::is_shell_component(c) => {
                bail!("There cannot be more than a single shell per page. \n\
                You are trying to open the {c:?} component, but a shell component is already opened for the current page. \n\
                You can fix this by removing the extra shell component, or by moving this component to the top of the SQL file, before any other component that displays data. \n")
            }
            (None, None) => {
                self.open_component_with_data(DEFAULT_COMPONENT, &JsonValue::Null)
                    .await?;
                self.render_current_template_with_data(&data).await?;
            }
            (_, Some(new_component)) => {
                self.open_component_with_data(new_component, &data).await?;
            }
            (Some(_current_component), None) => {
                self.render_current_template_with_data(&data).await?;
            }
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
        log::error!("SQL error: {:?}", error);
        self.close_component()?;
        let data = if self.app_state.config.environment.is_prod() {
            json!({
                "description": format!("Please contact the administrator for more information. The error has been logged."),
            })
        } else {
            json!({
                "query_number": self.current_statement,
                "description": error.to_string(),
                "backtrace": get_backtrace(error),
                "note": "You can hide error messages like this one from your users by setting the 'environment' configuration option to 'production'."
            })
        };
        let saved_component = self.open_component_with_data("error", &data).await?;
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

    async fn render_current_template_with_data<T: Serialize>(
        &mut self,
        data: &T,
    ) -> anyhow::Result<()> {
        if self.current_component.is_none() {
            self.set_current_component(DEFAULT_COMPONENT).await?;
        }
        self.current_component
            .as_mut()
            .expect("just set the current component")
            .render_item(&mut self.writer, json!(data))?;
        self.shell_renderer
            .render_item(&mut self.writer, JsonValue::Null)?;
        Ok(())
    }

    async fn create_renderer(
        component: &str,
        app_state: Arc<AppState>,
        component_index: usize,
        nonce: u64,
    ) -> anyhow::Result<SplitTemplateRenderer> {
        let split_template = app_state
            .all_templates
            .get_template(&app_state, component)
            .await?;
        Ok(SplitTemplateRenderer::new(
            split_template,
            app_state,
            component_index,
            nonce,
        ))
    }

    /// Set a new current component and return the old one
    async fn set_current_component(
        &mut self,
        component: &str,
    ) -> anyhow::Result<Option<SplitTemplateRenderer>> {
        let current_component_index = self
            .current_component
            .as_ref()
            .map_or(1, |c| c.component_index);
        let new_component = Self::create_renderer(
            component,
            Arc::clone(&self.app_state),
            current_component_index + 1,
            self.request_context.content_security_policy.nonce,
        )
        .await?;
        Ok(self.current_component.replace(new_component))
    }

    async fn open_component_with_data<T: Serialize>(
        &mut self,
        component: &str,
        data: &T,
    ) -> anyhow::Result<Option<SplitTemplateRenderer>> {
        self.close_component()?;
        let old_component = self.set_current_component(component).await?;
        self.current_component
            .as_mut()
            .expect("just set the current component")
            .render_start(&mut self.writer, json!(data))?;
        Ok(old_component)
    }

    fn close_component(&mut self) -> anyhow::Result<()> {
        if let Some(old_component) = self.current_component.as_mut().take() {
            old_component.render_end(&mut self.writer)?;
        }
        Ok(())
    }

    pub async fn close(mut self) -> W {
        if let Some(old_component) = self.current_component.as_mut().take() {
            let res = old_component
                .render_end(&mut self.writer)
                .map_err(|e| format_err!("Unable to render the component closing: {e}"));
            self.handle_result_and_log(&res).await;
        }
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
    component_index: usize,
    nonce: JsonValue,
}

impl SplitTemplateRenderer {
    fn new(
        split_template: Arc<SplitTemplate>,
        app_state: Arc<AppState>,
        component_index: usize,
        nonce: u64,
    ) -> Self {
        Self {
            split_template,
            local_vars: None,
            app_state,
            row_index: 0,
            ctx: Context::null(),
            component_index,
            nonce: nonce.into(),
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
        log::trace!(
            "Starting rendering of a template{} with the following top-level parameters: {data}",
            self.split_template
                .name()
                .map(|n| format!(" ('{n}')"))
                .unwrap_or_default(),
        );
        let mut render_context = handlebars::RenderContext::new(None);
        let blk = render_context
            .block_mut()
            .expect("context created without block");
        blk.set_local_var("component_index", self.component_index.into());
        blk.set_local_var("csp_nonce", self.nonce.clone());

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
            blk.set_local_var("component_index", self.component_index.into());
            blk.set_local_var("row_index", self.row_index.into());
            blk.set_local_var("csp_nonce", self.nonce.clone());
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
        log::trace!(
            "Closing a template {}",
            self.split_template
                .name()
                .map(|name| format!("('{name}')"))
                .unwrap_or_default(),
        );
        if let Some(mut local_vars) = self.local_vars.take() {
            let mut render_context = handlebars::RenderContext::new(None);
            local_vars.put("row_index", self.row_index.into());
            local_vars.put("component_index", self.component_index.into());
            local_vars.put("csp_nonce", self.nonce.clone());
            log::trace!("Rendering the after_list template with the following local variables: {local_vars:?}");
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
    use crate::app_config;
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
        let config = app_config::tests::test_config();
        let app_state = Arc::new(AppState::init(&config).await.unwrap());
        let mut rdr = SplitTemplateRenderer::new(Arc::new(split), app_state, 0, 0);
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
        let config = app_config::tests::test_config();
        let app_state = Arc::new(AppState::init(&config).await.unwrap());
        let mut rdr = SplitTemplateRenderer::new(Arc::new(split), app_state, 0, 0);
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
