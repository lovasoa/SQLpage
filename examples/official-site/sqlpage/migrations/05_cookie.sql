-- Insert the cookie component into the component table
INSERT INTO component (name, description, icon)
VALUES (
        'cookie',
        'Sets a cookie in the client browser, used for session management and storing user-related information.
        
        This component creates a single cookie. Since cookies need to be set before the response body is sent to the client,
        this component should be placed at the top of the page, before any other components that generate output.
        
        After being set, a cookie can be accessed anywhere in your SQL code using the `sqlpage.cookie(''cookie_name'')` pseudo-function.',
        'cookie'
    );
-- Insert the parameters for the cookie component into the parameter table
INSERT INTO parameter (
        component,
        name,
        description,
        type,
        top_level,
        optional
    )
VALUES (
        'cookie',
        'name',
        'The name of the cookie to set.',
        'TEXT',
        TRUE,
        FALSE
    ),
    (
        'cookie',
        'value',
        'The value of the cookie to set.',
        'TEXT',
        TRUE,
        TRUE
    ),
    (
        'cookie',
        'path',
        'The path for which the cookie will be sent. If not specified, the cookie will be sent for all paths.',
        'TEXT',
        TRUE,
        TRUE
    ),
    (
        'cookie',
        'domain',
        'The domain for which the cookie will be sent. If not specified, the cookie will be sent for all domains.',
        'TEXT',
        TRUE,
        TRUE
    ),
    (
        'cookie',
        'secure',
        'Whether the cookie should only be sent over a secure (HTTPS) connection. Defaults to TRUE.',
        'BOOLEAN',
        TRUE,
        TRUE
    ),
    (
        'cookie',
        'http_only',
        'Whether the cookie should only be accessible via HTTP and not via client-side scripts. If not specified, the cookie will be accessible via both HTTP and client-side scripts.',
        'BOOLEAN',
        TRUE,
        TRUE
    ),
    (
        'cookie',
        'remove',
        'Set to TRUE to remove the cookie from the client browser. When specified, other parameters are ignored.',
        'BOOLEAN',
        TRUE,
        TRUE
    ),
    (
        'cookie',
        'max_age',
        'The maximum age of the cookie in seconds. number of seconds until the cookie expires. If both Expires and Max-Age are set, Max-Age has precedence.',
        'INTEGER',
        TRUE,
        TRUE
    ),
    (
        'cookie',
        'expires',
        'The date at which the cookie expires (either a timestamp or a date object). If not specified, the cookie will expire when the browser is closed.',
        'TIMESTAMP',
        TRUE,
        TRUE
    ),
    (
        'cookie',
        'same_site',
        'Whether the cookie should only be sent for requests originating from the same site. See owasp.org/www-community/SameSite. `strict` is the recommended and default value, but you may want to set it to `lax` if you want your users to keep their session when they click on a link to your site from an external site.',
        'TEXT',
        TRUE,
        TRUE
    );
-- Insert an example usage of the cookie component into the example table
INSERT INTO example (component, description)
VALUES (
        'cookie',
        'Create a cookie named `username` with the value `John Doe`...

```sql
SELECT ''cookie'' as component,
        ''username'' as name,
        ''John Doe'' as value
        FALSE AS secure; -- You can remove this if the site is served over HTTPS.
```

and then display the value of the cookie using the [`sqlpage.cookie`](functions.sql?function=cookie) function:
    
```sql
SELECT ''text'' as component,
         ''Your name is '' || COALESCE(sqlpage.cookie(''username''), ''not known to us'');
```
        '
    );