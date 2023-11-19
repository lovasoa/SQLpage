# CHANGELOG.md

## unreleased

 - Add special handling of hidden inputs in [forms](https://sql.ophir.dev/documentation.sql?component=form#component). Hidden inputs are now completely invisible to the end user, facilitating the implementation of multi-step forms, csrf protaction, and other complex forms.
 - 18 new icons available (see https://github.com/tabler/tabler-icons/releases/tag/v2.40.0)
 - Support multiple statements in [`on_connect.sql`](./configuration.md) in MySQL.
 - Randomize postgres prepared statement names to avoid name collisions. This should fix a bug where SQLPage would report errors like `prepared statement "sqlx_s_3" already exists` when using a connection pooler in front of a PostgreSQL database.
 - SQL statements are now prepared lazily right before their first execution, instead of all at once when a file is first loaded, which allows **referencing a temporary table created at the start of a file in a later statement** in the same file. This works by delegating statement preparation to the database interface library we use (sqlx). The logic of preparing statements and caching them for later reuse is now entirely delegated to sqlx. This also nicely simplifies the code and logic inside sqlpage itself, and should slightly improve performance and memory usage.

## 0.15.2 (2023-11-12)

 - Several improvements were made to the **map** component
  - Fix a bug where the new geojson support in the map component would not work when the geojson was passed as a string. This impacted databases that do not support native json objects, such as SQLite.
  - Improve support for geojson points (in addition to polygons and lines) in the map component.
  - Add a new `size` parameter to the map component to set the size of markers.
  - Document the `height` parameter to customize the size of the map.
  - `tile_source` parameter to customize the map tiles, giving completely free control over the map appearance.
  - `attribution` parameter to customize or remove the small copyright information text box at the bottom of the map. 
  - Add the ability to customize top navigation links and to create submenus in the `shell` component.
    - Postgres example:
    ```sql
    select 
      'shell' as component,
      'SQLPage' as title,
      JSON('{ "link":"/", "title":"Home" }') as menu_item,
      JSON('{ "title":"Options", "submenu":[
          {"link":"1.sql","title":"Page 1"},
          {"link":"2.sql","title":"Page 2"}
      ]}') as menu_item;
    ```
    - *note*: this requires a database that supports json objects natively. If you are using SQLite, you can work around this limitation by using the `dynamic` component.
 - Updated the embedded database to [SQLite 3.44](https://antonz.org/sqlite-3-44/), which improves performance, compatibility with other databases, and brings new date formatting functions. The new `ORDER BY` clause in aggregate functions is not supported yet in SQLPage.

## 0.15.1 (2023-11-07)

 - Many improvements in the [`form`](https://sql.ophir.dev/documentation.sql?component=form#component) component
   - Multiple form fields can now be aligned on the same line using the `width` attribute.
   - A *reset* button can now be added to the form using the `reset` top-level attribute.
   - The *submit* button can now be customized, and can be removed completely, which is useful to create multiple submit buttons that submit the form to different targets.
 - Support non-string values in markdown fields. `NULL` values are now displayed as empty strings, numeric values are displayed as strings, booleans as `true` or `false`, and arrays as lines of text. This avoids the need to cast values to strings in SQL queries.
 - Revert a change introduced in v0.15.0:
    - Re-add the systematic `CAST(? AS TEXT)` around variables, which helps the database know which type it is dealing with in advance. This fixes a regression in 0.15 where some SQLite websites were broken because of missing affinity information. In SQLite `SELECT '1' = 1` returns `false` but `SELECT CAST('1' AS TEXT) = 1` returns `true`. This also fixes error messages like `could not determine data type of parameter $1` in PostgreSQL.
 - Fix a bug where [cookie](https://sql.ophir.dev/documentation.sql?component=cookie#component) removal set the cookie value to the empty string instead of removing the cookie completely.
 - Support form submission using the [button](https://sql.ophir.dev/documentation.sql?component=button#component) component using its new `form` property. This allows you to create a form with multiple submit buttons that submit the form to different targets.
 - Custom icons and colors for markers in the [map](https://sql.ophir.dev/documentation.sql?component=map#component) component.
 - Add support for GeoJSON in the [map](https://sql.ophir.dev/documentation.sql?component=map#component) component. This makes it much more generic and allows you to display any kind of geographic data, including areas, on a map very easily. This plays nicely with PostGIS and Spatialite which can return GeoJSON directly from SQL queries.

## 0.15.0 (2023-10-29)
 - New function: [`sqlpage.path`](https://sql.ophir.dev/functions.sql?function=path#function) to get the path of the current page.
 - Add a new `align_right` attribute to the [table](https://sql.ophir.dev/documentation.sql?component=table#component) component to align a column to the right.
 - Fix display of long titles in the shell component.
 - New [`sqlpage.variables`](https://sql.ophir.dev/functions.sql?function=variables#function) function for easy handling of complex forms
    - `sqlpage.variables('get')` returns a json object containing all url parameters. Inside `/my_page.sql?x=1&y=2`, it returns the string `'{"x":"1","y":"2"}'`
    - `sqlpage.variables('post')` returns a json object containg all variables passed through a form. This makes it much easier to handle a form with a variable number of fields.
 - Remove systematic casting in SQL of all parameters to `TEXT`. The supported databases understand the type of the parameters natively.
  - Some advanced or database-specific SQL syntax that previously failed to parse inside SQLPage is now supported. See [updates in SQLParser](https://github.com/sqlparser-rs/sqlparser-rs/blob/main/CHANGELOG.md#added)


## 0.14.0 (2023-10-19)

 - Better support for time series in the [chart](https://sql.ophir.dev/documentation.sql?component=chart#component) component. You can now use the `time` top-attribute to display a time series chart
 with smart x-axis labels.
 - **New component**: [button](https://sql.ophir.dev/documentation.sql?component=button#component). This allows you to create rows of buttons that allow navigation between pages.
 - Better error messages for Microsoft SQL Server. SQLPage now displays the line number of the error, which is especially useful for debugging long migration scripts.
 - Many improvements in the official website and the documentation.
    - Most notably, the documentation now has syntax highlighting on code blocks (using [prism](https://prismjs.com/) with a custom theme made for tabler). This also illustrates the usage of external javascript and css libraries in SQLPage. See [the shell component documentation](https://sql.ophir.dev/documentation.sql?component=shell#component).
    - Better display of example queries in the documentation, with smart indentation that makes it easier to read.
 - Clarify some ambiguous error messages:
   - make it clearer whether the error comes from SQLPage or from the database
   - specific tokenization errors are now displayed as such

## 0.13.0 (2023-10-16)
 - New [timeline](https://sql.ophir.dev/documentation.sql?component=timeline#component) component to display a timeline of events.
 - Add support for scatter and bubble plots in the chart component. See [the chart documentation](https://sql.ophir.dev/documentation.sql?component=chart#component).
 - further improve debuggability with more precise error messages. In particular, it usd to be hard to debug errors in long migration scripts, because the line number and position was not displayed. This is now fixed.
 - Better logs on 404 errors. SQLPage used to log a message without the path of the file that was not found. This made it hard to debug 404 errors. This is now fixed.
 - Add a new `top_image` attribute to the [card](https://sql.ophir.dev/documentation.sql?component=card#component) component to display an image at the top of the card. This makes it possible to create beautiful image galleries with SQLPage.
 - Updated dependencies, for bug fixes and performance improvements.
 - New icons (see https://tabler-icons.io/changelog)
 - When `NULL` is passed as an icon name, display no icon instead of raising an error.
 - Official docker image folder structure changed. The docker image now expects 
   - the SQLPage website (`.sql` files) to be in `/var/www/`, and
   - the SQLPage configuration folder to be in `/etc/sqlpage/`
    - the configuration file should be in `/etc/sqlpage/sqlpage.json`
    - the database file should be in `/etc/sqlpage/sqlpage.db`
    - custom templates should be in `/etc/sqlpage/templates/`
   - This configuration change concerns only the docker image. If you are using the sqlpage binary directly, nothing changes.

## 0.12.0 (2023-10-04)

 - **variables** . SQLPage now support setting and reusing variables between statements. This allows you to write more complex SQL queries, and to reuse the result of a query in multiple places.
   ```sql
   -- Set a variable
   SET person = (select username from users where id = $id);
   -- Use it in a query
   SELECT 'text' AS component, 'Hello ' || $person AS contents;
   ```
 - *asynchronous password hashing* . SQLPage used to block a request processing thread while hashing passwords. This could cause a denial of service if an attacker sent many requests to a page that used `sqlpage.hash_password()`
 (typically, the account creation page of your website).
  SQLPage now launches password hashing operations on a separate thread pool, and can continue processing other requests while waiting for passwords to be hashed.
 - Easier configuration for multiple menu items. Syntax like `SELECT 'shell' as component, '["page 1", "page 2"]' as menu_item'` now works as expected. See the new `sqlpage_shell` definition in [the small sql game example](./examples/corporate-conundrum/) and [this discussion](https://github.com/lovasoa/SQLpage/discussions/91).
 - New `sqlpage.exec` function to execute a command on the server. This allows you to run arbitrary code on the server, and use the result in your SQL queries. This can be used to make external API calls, send emails, or run any other code on the server.
  ```sql
  select 'card' as component;
  select value->>'name' as title, value->>'email' as description
  from json_each(sqlpage.exec('curl', 'https://jsonplaceholder.typicode.com/users'));
   ```

   This function is disabled by default for security reasons. To enable it, set the `allow_exec` configuration parameter to `true` in the [configuration](./configuration.md). Enabling it gives full access to the server to anyone who can write SQL queries on your website (this includes users with access to the local filesystem and users with write access to the `sqlpage_files` table on your database), so be careful !
 - New `sqlpage.url_encode` function to percent-encode URL parameters.
   ```sql
   select 'card' as component;
   select 'More...' as title, 'advanced_search.sql?query=' || sqlpage.url_encode($query)
   ```
 - Add the ability to run a sql script on each database connection before it is used,
   by simply creating `sqlpage/on_connect.sql` file. This has many interesting use cases:
     - allows you to set up your database connection with custom settings, such as `PRAGMA` in SQLite
     - set a custom `search_path`, `application_name` or other variables in PostgreSQL
     - create temporary tables that will be available to all SQLPage queries but will not be persisted in the database
     - [`ATTACH`](https://www.sqlite.org/lang_attach.html) a database in SQLite to query multiple database files at once
 - Better error messages. SQLPage displays a more precise and useful message when an error occurs, and displays the position in the SQL statement where the error occured. Incorrect error messages on invalid migrations are also fixed.
 - We now distribute docker images from ARM too. Say hello to SQLPage on your Raspberry Pi and your Mac M1 !
 - Create the default SQLite database file in the "sqlpage" config directory instead of at the root of the web server by default. This makes it inaccessible from the web, which is a more secure default. If you want to keep the old behavior, set the `database_url` configuration parameter to `sqlite://sqlpage.db` in your [configuration](./configuration.md).
 - New `empty_title`, `empty_description`, and `empty_link` top-level attributes on the [`list`](https://sql.ophir.dev/documentation.sql?component=list#component) component to customize the text displayed when the list is empty.

## 0.11.0 (2023-09-17)
 - Support for **environment variables** ! You can now read environment variables from sql code using `sqlpage.environment_variable('VAR_NAME')`.
 - Better support for connection options in mssql.
 - New icons (see https://tabler-icons.io/changelog)
 - New version of the CSS library (see https://preview.tabler.io/changelog.html)
 - configurable web root (see [configuration.md](./configuration.md))
 - new welcome message 
   - ```
      SQLPage is now running on http://127.0.0.1:8080/
      You can write your code in .sql files in /path/to/your/website/directory.
      ```
 - New `sqlpage.current_working_directory` function to get the [current working directory](https://en.wikipedia.org/wiki/Working_directory) of the SQLPage process.
  - New `sqlpage.version` function to get the version of SQLPage.

## 0.10.3 (2023-09-14)

 - Update database drivers to the latest version.
   - Adds new connection string options for mssql, including `app_name` and `instance`.
     Set them with `DATABASE_URL=mssql://user:password@host:port/database?app_name=My%20App&instance=My%20Instance` 

## 0.10.2 (2023-09-04)

 - Fix a bug where the `map` component followed by another component would break the page layout.

## 0.10.1 (2023-08-27)
 - Update the SQL parser, with multiple fixes. See https://github.com/sqlparser-rs/sqlparser-rs/blob/main/CHANGELOG.md#0370-2023-08-22
 - Display all parameters in the debug component (instead of only row-level parameters).
 - Update dashmap for better file lookup performance.
 - Fix table sorting.
 - Fix a bug with Basic Authentication.
   See [#72](https://github.com/lovasoa/SQLpage/pull/72). Thanks to @edgrip for the contribution !

## 0.10.0 (2023-08-20)

 - `.sql` files are now parsed in the dialect of the database they are executed against,
   instead of always being parsed as a "Generic" dialect.
   This allows using more database-specific features in SQLPage and avoids confusion.
   This should not change anything in most cases, but could break your web application
   if you were relying on an SQL dialect syntax that is not directly supported by your database,
   hence the major version change.
 - Added the ability to download chart data as SVG, PNG, and **CSV** using the new `toolbar` attribute of the `chart` component.
   This makes it easy to provide a large data set and allow users to download it as a CSV file from a nice UI.
   ```sql
   SELECT 'chart' as component, 1 as toolbar;
   SELECT quarter as label, sum(sales) as value FROM sales GROUP BY quarter;
   ```
 - Added a dark theme ! You can now choose between a light and a dark theme for your SQLPage website.
   Select the dark theme using the `theme` parameter of the `shell` component:
   ```sql
   SELECT 'shell' AS component, 'dark' AS theme;
   ```
   See https://github.com/lovasoa/SQLpage/issues/50
 - Fixed a bug where the default index page would be displayed when `index.sql` could not be loaded,
   instead of displaying an error page explaining the issue.
 - Improved the appearance of scrollbars. (Workaround for https://github.com/tabler/tabler/issues/1648).
   See https://github.com/lovasoa/SQLpage/discussions/17
 - Create a single database connection by default when using `sqlite://:memory:` as the database URL.
   This makes it easier to use temporary tables and other connection-specific features.
 - When no component is selected, display data with the `debug` component by default.
   This makes any simple `SELECT` statement a valid SQLPage file.
   Before, data returned outside of a component would be ignored.
 - Improved error handling. SQLPage now displays a nice error page when an error occurs, even if it's at the top of the page.
   This makes it easier to debug SQLPage websites. Before, errors that occured before SQLPage had started to render the page would be displayed as a raw text error message without any styling.
 - Added the ability to retry database connections when they fail on startup.
   This makes it easier to start SQLPage concurrently with the database, and have it wait for the database to become available.
   See the [`database_connection_retries` and `database_connection_acquire_timeout_seconds` configuration parameter](./configuration.md).

## 0.9.5 (2023-08-12)

 - New `tab` component to create tabbed interfaces. See [the documentation](https://sql.ophir.dev/documentation.sql?component=tab#component).
 - Many improvements in database drivers.
   - performance and numeric precision improvements,
   - multiple fixes around passing NUMERIC, DECIMAL, and JSON values to SQLPage.

## 0.9.4 (2023-08-04)

Small bugfix release

 - Fix a bug with simple queries (ones with only static values) that contained multiple repeated columns
   (such as `SELECT 'hello' AS menu_item, 'world' AS menu_item`). Only the last column would be taken into account.
   This could manifest as a bug where
     - only the last menu item in the shell component would be displayed,
     - only the last markdown column in a table would be interpreted as markdown,
     - only the last icon column in a table would be displayed as an icon.

## 0.9.3 (2023-08-03)

 - Icons are now loaded directly from the sqlpage binary instead of loading them from a CDN.
  This allows pages to load faster, and to get a better score on google's performance audits, potentially improving your position in search results.
    - This also makes it possible to host a SQLPage website on an intranet without access to the internet.
    - Fixes https://github.com/lovasoa/SQLpage/issues/37
 - store compressed frontend assets in the SQLPage binary:
    - smaller SQLPage binary
    - Faster page loads, less work on the server
 - Fix a bug where table search would fail to find a row if the search term contained some special characters.
    - Fixes https://github.com/lovasoa/SQLpage/issues/46
 - Split the charts javascript code from the rest of the frontend code, and load it only when necessary.
   This greatly diminishes the amount of js loaded by default, and achieves very good performance scores by default.
   SQLPage websites now load even faster, een on slow mobile connections.

## 0.9.2 (2023-08-01)

 - Added support for more SQL data types. This notably fixes an issue with the display of datetime columns in tables.
    - See: https://github.com/lovasoa/SQLpage/issues/41
 - Updated dependencies, better SQL drivers

## 0.9.1 (2023-07-30)

 - Fix issues with the new experimental mssql driver.

## 0.9.0 (2023-07-30)

 - Added a new `json` component, which allows building a JSON API entirely in SQL with SQLPage !
   Now creating an api over your database is as simple as `SELECT 'json' AS component, JSON_OBJECT('hello', 'world') AS contents`.
 - `SELECT` statements that contain only static values are now interpreted directly by SQLPage, and do not result in a database query. This greatly improves the performance of pages that contain many static elements.
 - Redirect index pages without a trailing slash to the same page with the trailing slash. This ensures that relative links work correctly, and gives each page a unique canonical URL. (For instance, if you have a file in `myfolder/index.sql`, then it will be accessible at `mysite.com/myfolder/` and `mysite.com/myfolder` will redirect to `mysite.com/myfolder/`).
 - Update the database drivers to the latest version, and switch to a fork of `sqlx`. This also updates the embedded version of SQLite to 3.41.2, with [many cool new features](https://www.sqlite.org/changes.html) such as:
   - better json support
   - better performance
 - Add experimental support for *Microsoft SQL Server*. If you have a SQL Server database lying around, please test it and report any issue you might encounter !

## 0.8.0 (2023-07-17)

 - Added a new [`sqlite_extensions` configuration parameter](./configuration.md) to load SQLite extensions. This allows many interesting use cases, such as 
      - [using spatialite to build a geographic data application](./examples/make%20a%20geographic%20data%20application%20using%20sqlite%20extensions/),
      - querying CSV data from SQLPage with [vsv](https://github.com/nalgeon/sqlean/blob/main/docs/vsv.md),
      - or building a search engine for your data with [FTS5](https://www.sqlite.org/fts5.html).
 - Breaking: change the order of priority for loading configuration parameters: the environment variables have priority over the configuration file. This makes it easier to tweak the configuration of a SQLPage website when deploying it.
 - Fix the default index page in MySQL. Fixes [#23](https://github.com/lovasoa/SQLpage/issues/23).
 - Add a new [map](https://sql.ophir.dev/documentation.sql?component=map#component) component to display a map with markers on it. Useful to display geographic data from PostGIS or Spatialite.
 - Add a new `icon` attribute to the [table](https://sql.ophir.dev/documentation.sql?component=table#component) component to display icons in the table.
 - Fix `textarea` fields in the [form](https://sql.ophir.dev/documentation.sql?component=table#component) component to display the provided `value` attribute. Thanks Frank for the contribution !
 - SQLPage now guarantees that a single web request will be handled by a single database connection. Previously, connections were repeatedly taken and put back to the connection pool between each statement, preventing the use of temporary tables, transactions, and other connection-specific features such as [`last_insert_rowid`](https://www.sqlite.org/lang_corefunc.html#last_insert_rowid). This makes it much easier to keep state between SQL statements in a single `.sql` file. Please report any performance regression you might encounter. See [the many-to-many relationship example](./examples/modeling%20a%20many%20to%20many%20relationship%20with%20a%20form/).
 - The [table](https://sql.ophir.dev/documentation.sql?component=table#component) component now supports setting a custom background color, and a custom CSS class on a given table line.
 - New `checked` attribute for checkboxes and radio buttons. 

## 0.7.2 (2023-07-10)

### [SQL components](https://sql.ophir.dev/documentation.sql)

 - New [authentication](https://sql.ophir.dev/documentation.sql?component=authentication#component) component to handle user authentication, and password checking
 - New [redirect](https://sql.ophir.dev/documentation.sql?component=redirect#component) component to stop rendering the current page and redirect the user to another page.
 - The [debug](https://sql.ophir.dev/documentation.sql?component=debug#component) component is now documented
 - Added properties to the [shell](https://sql.ophir.dev/documentation.sql?component=shell#component) component:
    - `css` to add custom CSS to the page
    - `javascript` to add custom Javascript to the page. An example of [how to use it to integrate a react component](https://github.com/lovasoa/SQLpage/tree/main/examples/using%20react%20and%20other%20custom%20scripts%20and%20styles) is available.
    - `footer` to set a message in the footer of the page

### [SQLPage functions](https://sql.ophir.dev/functions.sql)

 - New [`sqlpage.basic_auth_username`](https://sql.ophir.dev/functions.sql?function=basic_auth_username#function) function to get the name of the user logged in with HTTP basic authentication
 - New [`sqlpage.basic_auth_password`](https://sql.ophir.dev/functions.sql?function=basic_auth_password#function) function to get the password of the user logged in with HTTP basic authentication.
 - New [`sqlpage.hash_password`](https://sql.ophir.dev/functions.sql?function=hash_password#function) function to hash a password with the same algorithm as the [authentication](https://sql.ophir.dev/documentation.sql?component=authentication#component) component uses.
 - New [`sqlpage.header`](https://sql.ophir.dev/functions.sql?function=header#function) function to read an HTTP header from the request.
 - New [`sqlpage.random_string`](https://sql.ophir.dev/functions.sql?function=random_string#function) function to generate a random string. Useful to generate session ids.


### Bug fixes

 - Fix a bug where the page style would not load in pages that were not in the root directory: https://github.com/lovasoa/SQLpage/issues/19
 - Fix resources being served with the wrong content type
 - Fix compilation of SQLPage as an AWS lambda function
 - Fixed logging and display of errors, to make them more useful
