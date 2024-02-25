use anyhow::Context;
use config::Config;
use serde::de::Error;
use serde::{Deserialize, Deserializer};
use std::net::{SocketAddr, ToSocketAddrs};
use std::path::PathBuf;

#[cfg(not(feature = "lambda-web"))]
const DEFAULT_DATABASE_FILE: &str = "sqlpage.db";

#[derive(Debug, Deserialize, PartialEq, Clone)]
pub struct AppConfig {
    #[serde(default = "default_database_url")]
    pub database_url: String,
    pub max_database_pool_connections: Option<u32>,
    pub database_connection_idle_timeout_seconds: Option<f64>,
    pub database_connection_max_lifetime_seconds: Option<f64>,

    #[serde(default)]
    pub sqlite_extensions: Vec<String>,

    #[serde(default, deserialize_with = "deserialize_socket_addr")]
    pub listen_on: Option<SocketAddr>,
    pub port: Option<u16>,

    /// Number of times to retry connecting to the database after a failure when the server starts
    /// up. Retries will happen every 5 seconds. The default is 6 retries, which means the server
    /// will wait up to 30 seconds for the database to become available.
    #[serde(default = "default_database_connection_retries")]
    pub database_connection_retries: u32,

    /// Maximum number of seconds to wait before giving up when acquiring a database connection from the
    /// pool. The default is 10 seconds.
    #[serde(default = "default_database_connection_acquire_timeout_seconds")]
    pub database_connection_acquire_timeout_seconds: f64,

    /// The directory where the .sql files are located. Defaults to the current directory.
    #[serde(default = "default_web_root")]
    pub web_root: PathBuf,

    /// The directory where the sqlpage configuration file is located. Defaults to `./sqlpage`.
    #[serde(default = "configuration_directory")]
    pub configuration_directory: PathBuf,

    /// Set to true to allow the `sqlpage.exec` function to be used in SQL queries.
    /// This should be enabled only if you trust the users writing SQL queries, since it gives
    /// them the ability to execute arbitrary shell commands on the server.
    #[serde(default)]
    pub allow_exec: bool,

    /// Maximum size of uploaded files in bytes. The default is 10MiB (10 * 1024 * 1024 bytes)
    #[serde(default = "default_max_file_size")]
    pub max_uploaded_file_size: usize,

    /// A domain name to use for the HTTPS server. If this is set, the server will perform all the necessary
    /// steps to set up an HTTPS server automatically. All you need to do is point your domain name to the
    /// server's IP address.
    ///
    /// It will listen on port 443 for HTTPS connections,
    /// and will automatically request a certificate from Let's Encrypt
    /// using the ACME protocol (requesting a TLS-ALPN-01 challenge).
    pub https_domain: Option<String>,

    /// The email address to use when requesting a certificate from Let's Encrypt.
    /// Defaults to `contact@<https_domain>`.
    pub https_certificate_email: Option<String>,

    /// The directory to store the Let's Encrypt certificate in. Defaults to `./sqlpage/https`.
    #[serde(default = "default_https_certificate_cache_dir")]
    pub https_certificate_cache_dir: PathBuf,

    /// URL to the ACME directory. Defaults to the Let's Encrypt production directory.
    #[serde(default = "default_https_acme_directory_url")]
    pub https_acme_directory_url: String,

    /// Whether SQLPage is running in development or production mode. This is used to determine
    /// whether to show error messages to the user.
    #[serde(default)]
    pub environment: DevOrProd,
}

impl AppConfig {
    #[must_use]
    pub fn listen_on(&self) -> SocketAddr {
        let mut addr = self.listen_on.unwrap_or_else(|| {
            if self.https_domain.is_some() {
                SocketAddr::from(([0, 0, 0, 0], 443))
            } else {
                SocketAddr::from(([0, 0, 0, 0], 8080))
            }
        });
        if let Some(port) = self.port {
            addr.set_port(port);
        }
        addr
    }
}

/// The directory where the `sqlpage.json` file is located.
/// Determined by the `SQLPAGE_CONFIGURATION_DIRECTORY` environment variable
fn configuration_directory() -> PathBuf {
    std::env::var("SQLPAGE_CONFIGURATION_DIRECTORY")
        .or_else(|_| std::env::var("CONFIGURATION_DIRECTORY"))
        .map_or_else(|_| PathBuf::from("sqlpage"), PathBuf::from)
}

fn cannonicalize_if_possible(path: &std::path::Path) -> PathBuf {
    path.canonicalize().unwrap_or_else(|_| path.to_owned())
}

pub fn load() -> anyhow::Result<AppConfig> {
    let configuration_directory = &configuration_directory();
    log::debug!(
        "Loading configuration from {:?}",
        cannonicalize_if_possible(configuration_directory)
    );
    let config_file = configuration_directory.join("sqlpage");
    Config::builder()
        .add_source(config::File::from(config_file).required(false))
        .add_source(env_config())
        .add_source(env_config().prefix("SQLPAGE"))
        .build()?
        .try_deserialize::<AppConfig>()
        .with_context(|| "Unable to load configuration")
}

fn env_config() -> config::Environment {
    config::Environment::default()
        .try_parsing(true)
        .list_separator(" ")
        .with_list_parse_key("sqlite_extensions")
}

fn deserialize_socket_addr<'de, D: Deserializer<'de>>(
    deserializer: D,
) -> Result<Option<SocketAddr>, D::Error> {
    let host_str: Option<String> = Deserialize::deserialize(deserializer)?;
    host_str
        .map(|h| parse_socket_addr(&h).map_err(D::Error::custom))
        .transpose()
}

fn parse_socket_addr(host_str: &str) -> anyhow::Result<SocketAddr> {
    host_str
        .to_socket_addrs()?
        .next()
        .with_context(|| format!("host '{host_str}' does not resolve to an IP"))
}

fn default_database_url() -> String {
    let prefix = "sqlite://".to_owned();

    if cfg!(test) {
        return prefix + ":memory:";
    }

    #[cfg(not(feature = "lambda-web"))]
    {
        let config_dir = cannonicalize_if_possible(&configuration_directory());
        let old_default_db_path = PathBuf::from(DEFAULT_DATABASE_FILE);
        let default_db_path = config_dir.join(DEFAULT_DATABASE_FILE);
        if let Ok(true) = old_default_db_path.try_exists() {
            log::warn!("Your sqlite database in {old_default_db_path:?} is publicly accessible through your web server. Please move it to {default_db_path:?}.");
            return prefix + old_default_db_path.to_str().unwrap();
        } else if let Ok(true) = default_db_path.try_exists() {
            log::debug!("Using the default database file in {default_db_path:?}.");
            return prefix + default_db_path.to_str().unwrap();
        }
        // Create the default database file if we can
        let _ = std::fs::create_dir_all(default_db_path.parent().unwrap()); // may already exist
        if let Ok(tmp_file) = std::fs::File::create(&default_db_path) {
            log::info!("No DATABASE_URL provided, {default_db_path:?} is writable, creating a new database file.");
            drop(tmp_file);
            std::fs::remove_file(&default_db_path).expect("removing temp file");
            return prefix + default_db_path.to_str().unwrap() + "?mode=rwc";
        }
    }

    log::warn!("No DATABASE_URL provided, and the current directory is not writeable. Using a temporary in-memory SQLite database. All the data created will be lost when this server shuts down.");
    prefix + ":memory:"
}

fn default_database_connection_retries() -> u32 {
    6
}

fn default_database_connection_acquire_timeout_seconds() -> f64 {
    10.
}

fn default_web_root() -> PathBuf {
    std::env::current_dir().unwrap_or_else(|e| {
        log::error!("Unable to get current directory: {}", e);
        PathBuf::from(&std::path::Component::CurDir)
    })
}

fn default_max_file_size() -> usize {
    5 * 1024 * 1024
}

fn default_https_certificate_cache_dir() -> PathBuf {
    default_web_root().join("sqlpage").join("https")
}

fn default_https_acme_directory_url() -> String {
    "https://acme-v02.api.letsencrypt.org/directory".to_string()
}

#[derive(Debug, Deserialize, PartialEq, Clone, Copy, Eq, Default)]
#[serde(rename_all = "lowercase")]
pub enum DevOrProd {
    #[default]
    Development,
    Production,
}
impl DevOrProd {
    pub(crate) fn is_prod(self) -> bool {
        self == DevOrProd::Production
    }
}

#[cfg(test)]
pub mod tests {
    use super::AppConfig;

    #[must_use]
    pub fn test_config() -> AppConfig {
        serde_json::from_str::<AppConfig>(
            r#"{
            "database_url": "sqlite::memory:",
            "listen_on": "localhost:8080"
        }"#,
        )
        .unwrap()
    }
}
