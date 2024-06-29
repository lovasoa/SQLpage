CREATE TABLE component(
    name TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    icon TEXT, -- icon name from tabler icon
    introduced_in_version TEXT
);

CREATE TABLE parameter_type(
    name TEXT PRIMARY KEY
);
INSERT INTO parameter_type(name) VALUES
    ('BOOLEAN'), ('COLOR'), ('HTML'), ('ICON'), ('INTEGER'), ('JSON'), ('REAL'), ('TEXT'), ('TIMESTAMP'), ('URL');

CREATE TABLE parameter(
    top_level BOOLEAN DEFAULT FALSE,
    name TEXT,
    component TEXT REFERENCES component(name) ON DELETE CASCADE,
    description TEXT,
    description_md TEXT,
    type TEXT REFERENCES parameter_type(name) ON DELETE CASCADE,
    optional BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (component, top_level, name)
);

CREATE TABLE example(
    component TEXT REFERENCES component(name) ON DELETE CASCADE,
    description TEXT,
    properties JSON,
    FOREIGN KEY (component) REFERENCES component(name) ON DELETE CASCADE
);

INSERT INTO component(name, icon, description) VALUES
    ('list', 'list', 'A vertical list of items. Each item can be clickable and link to another page.');
INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'list', * FROM (VALUES
    -- top level
    ('title', 'Text header at the top of the list.', 'TEXT', TRUE, TRUE),
    ('empty_title', 'Title text to display if the list is empty.', 'TEXT', TRUE, TRUE),
    ('empty_description', 'Description to display if the list is empty.', 'TEXT', TRUE, TRUE),
    ('empty_description_md', 'Description to display if the list is empty, in Markdown format.', 'TEXT', TRUE, TRUE),
    ('empty_link', 'URL to which the user should be taken if they click on the empty list.', 'URL', TRUE, TRUE),
    ('compact', 'Whether to display the list in a more compact format, allowing more items to be displayed on the screen.', 'BOOLEAN', TRUE, TRUE),
    ('wrap', 'Wrap list items onto multiple lines if they are too long', 'BOOLEAN', TRUE, TRUE),
    -- item level
    ('title', 'Name of the list item, displayed prominently.', 'TEXT', FALSE, FALSE),
    ('description', 'A description of the list item, displayed as greyed-out text.', 'TEXT', FALSE, TRUE),
    ('description_md', 'A description of the list item, displayed as greyed-out text, in Markdown format, allowing you to use rich text formatting, including **bold** and *italic* text.', 'TEXT', FALSE, TRUE),
    ('link', 'An URL to which the user should be taken when they click on the list item.', 'URL', FALSE, TRUE),
    ('icon', 'Name of an icon to display on the left side of the item.', 'ICON', FALSE, TRUE),
    ('image_url', 'The URL of a small image to display on the left side of the item.', 'URL', FALSE, TRUE),
    ('color', 'The name of a color, to be displayed as a dot near the list item contents.', 'COLOR', FALSE, TRUE),
    ('active', 'Whether this item in the list is considered "active". Active items are displayed more prominently.', 'BOOLEAN', FALSE, TRUE),
    ('view_link', 'A URL to which the user should be taken when they click on the "view" icon. Does not show the icon when omitted.', 'URL', FALSE, TRUE),
    ('edit_link', 'A URL to which the user should be taken when they click on the "edit" icon. Does not show the icon when omitted.', 'URL', FALSE, TRUE),
    ('delete_link', 'A URL to which the user should be taken when they click on the "delete" icon. Does not show the icon when omitted.', 'URL', FALSE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('list', 'A basic compact list', json('[{"component":"list", "compact": true, "title": "SQLPage lists are..."},{"title":"Beautiful"},{"title":"Useful"},{"title":"Versatile"}]')),
    ('list', 'An empty list with a link to add an item', json('[{"component":"list", "empty_title": "No items yet", "empty_description": "This list is empty. Click here to create a new item !", "empty_link": "documentation.sql"}]')),
    ('list', 'A list with rich text descriptions', json('[{"component":"list", "wrap": true},
        {"title":"SQLPage", "image_url": "https://raw.githubusercontent.com/lovasoa/SQLpage/main/docs/favicon.png", "description_md":"A **SQL**-based **page** generator for **PostgreSQL**, **MySQL**, **SQLite** and **SQL Server**. [Free on Github](https://github.com/lovasoa/sqlpage)"},
        {"title":"Tabler", "image_url": "https://avatars.githubusercontent.com/u/35471246", "description_md":"A **free** and **open-source** **HTML** template pack based on **Bootstrap**."},
        {"title":"Tabler Icons", "image_url": "https://tabler.io/favicon.ico", "description_md":"A set of over **700** free MIT-licensed high-quality **SVG** icons for you to use in your web projects."}
    ]')),
    ('list', 'A beautiful list with bells and whistles.',
            json('[{"component":"list", "title":"Popular websites" }, '||
            '{"title":"Google", "link":"https://google.com", "description": "A search engine", "color": "red", "icon":"brand-google", "active": true }, '||
            '{"title":"Wikipedia", "link":"https://wikipedia.org", "description": "An encyclopedia", "color": "blue", "icon":"world", "edit_link": "?edit=wikipedia", "delete_link": "?delete=wikipedia" }]'));

INSERT INTO component(name, icon, description) VALUES
    ('datagrid', 'grid-dots', 'Display small pieces of information in a clear and readable way. Each item has a name and is associated with a value.');
INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'datagrid', * FROM (VALUES
    -- top level
    ('title', 'Text header at the top of the data grid.', 'TEXT', TRUE, TRUE),
    ('description', 'A short paragraph displayed below the title.', 'TEXT', TRUE, TRUE),
    ('description_md', 'A short paragraph displayed below the title - formatted using markdown.', 'TEXT', TRUE, TRUE),
    ('icon', 'Name of an icon to display on the left side of the title.', 'ICON', TRUE, TRUE),
    ('image_url', 'URL of an image to display on the left side of the title.', 'URL', TRUE, TRUE),
    -- item level
    ('title', 'Name of the piece of information.', 'TEXT', FALSE, FALSE),
    ('description', 'Value to display below the name.', 'TEXT', FALSE, TRUE),
    ('footer', 'Muted text to display below the value.', 'TEXT', FALSE, TRUE),
    ('image_url', 'URL of a small image (such as an avatar) to display on the left side of the value.', 'URL', FALSE, TRUE),
    ('link', 'A target URL to which the user should be taken when they click on the value.', 'URL', FALSE, TRUE),
    ('icon', 'An icon name (from tabler-icons.io) to display on the left side of the value.', 'ICON', FALSE, TRUE),
    ('color', 'If set to a color name, the value will be displayed in a pill of that color.', 'COLOR', FALSE, TRUE),
    ('active', 'Whether this item in the grid is considered "active". Active items are displayed more prominently.', 'BOOLEAN', FALSE, TRUE),
    ('tooltip', 'A tooltip to display when the user passes their mouse over the value.', 'TEXT', FALSE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('datagrid', 'Just some sections of information.', json('[{"component":"datagrid"},{"title":"Language","description":"SQL"},{"title":"Creation date","description":"1974"}, {"title":"Language family","description":"Query language"}]')),
    ('datagrid', 'A beautiful data grid with nice colors and icons.',
            json('[{"component":"datagrid", "title": "Ophir Lojkine", "image_url": "https://avatars.githubusercontent.com/u/552629", "description_md": "Member since **2021**"},
            {"title": "Pseudo", "description": "lovasoa", "image_url": "https://avatars.githubusercontent.com/u/552629" },
            {"title": "Status", "description": "Active", "color": "green"},
            {"title": "Email Status", "description": "Validated", "icon": "check", "active": true, "tooltip": "Email address has been validated."},
            {"title": "Personal page", "description": "ophir.dev", "link": "https://ophir.dev/", "tooltip": "About me"}
    ]')),
    ('datagrid', 'Using a picture in the data grid card header.', json('[
        {"component":"datagrid", "title": "Website Ideas", "icon": "bulb"},
            {"title": "Search engine", "link":"https://google.com", "description": "Google", "color": "red", "icon":"brand-google", "footer": "Owned by Alphabet Inc."},
            {"title": "Encyclopedia", "link":"https://wikipedia.org", "description": "Wikipedia", "color": "blue", "icon":"world", "footer": "Owned by the Wikimedia Foundation"}
    ]'));


INSERT INTO component(name, icon, description) VALUES
    ('steps', 'dots-circle-horizontal', 'Guide users through multi-stage processes, displaying a clear list of previous and future steps.');
INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'steps', * FROM (VALUES
    -- top level
    ('color', 'Color of the bars displayed between steps.', 'COLOR', TRUE, TRUE),
    ('counter', 'Display the number of the step on top of its name.', 'TEXT', TRUE, TRUE),
    ('title', 'Title of the section.', 'TEXT', TRUE, TRUE),
    ('description', 'Description of the section.', 'TEXT', TRUE, TRUE),
    -- item level
    ('title', 'Name of the step.', 'TEXT', FALSE, TRUE),
    ('description', 'Tooltip to display when the user passes their mouse over the step''s name.', 'TEXT', FALSE, TRUE),
    ('link', 'A target URL to which the user should be taken when they click on the step.', 'URL', FALSE, TRUE),
    ('icon', 'An icon name (from tabler-icons.io) to display on the left side of the step name.', 'ICON', FALSE, TRUE),
    ('active', 'Whether this item in the grid is considered "active". Active items are displayed more prominently.', 'BOOLEAN', FALSE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('steps', 'Online store checkout steps.', json('[{"component":"steps"},{"title":"Shopping"},{"title":"Store pickup"}, {"title":"Payment","active":true},{"title":"Review & Order"}]')),
    ('steps', 'A progress indicator with custom color, auto-generated step numbers, icons, and description tooltips.',
            json('[{"component":"steps", "counter": true, "color":"purple"}, '||
            '{"title": "Registration form", "icon":"forms", "link": "https://github.com/lovasoa/sqlpage", "description": "Initial account data creation."},' ||
            '{"title": "Email confirmation", "icon": "mail", "link": "https://sql.ophir.dev", "description": "Confirm your email by clicking on a link in a validation email."},' ||
            '{"title": "ID verification", "description": "Checking personal information", "icon": "user", "link": "#"},' ||
            '{"title": "Final account approval", "description": "ophir.dev", "link": "https://ophir.dev/", "icon":"eye-check", "active": true},' ||
            '{"title":"Account creation", "icon":"check"}]'));

INSERT INTO component(name, icon, description) VALUES
    ('text', 'align-left', 'A paragraph of text. The entire component will render as a single paragraph, with each item being rendered as a span of text inside it, the styling of which can be customized using parameters.');

INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'text', * FROM (VALUES
    -- top level
    ('title', 'Text header before the paragraph.', 'TEXT', TRUE, TRUE),
    ('center', 'Whether to center the title.', 'BOOLEAN', TRUE, TRUE),
    ('width', 'How wide the paragraph should be, in characters.', 'INTEGER', TRUE, TRUE),
    ('html', 'Raw html code to include on the page. Don''t use that if you are not sure what you are doing, it may have security implications.', 'TEXT', TRUE, TRUE),
    ('contents', 'A top-level paragraph of text to display, without any formatting, without having to make additional queries.', 'TEXT', TRUE, TRUE),
    ('contents_md', 'Rich text in the markdown format. Among others, this allows you to write bold text using **bold**, italics using *italics*, and links using [text](https://example.com).', 'TEXT', TRUE, TRUE),
    -- item level
    ('contents', 'A span of text to display', 'TEXT', FALSE, FALSE),
    ('contents_md', 'Rich text in the markdown format. Among others, this allows you to write bold text using **bold**, italics using *italics*, and links using [text](https://example.com).', 'TEXT', FALSE, TRUE),
    ('link', 'An URL to which the user should be taken when they click on this span of text.', 'URL', FALSE, TRUE),
    ('color', 'The name of a color for this span of text.', 'COLOR', FALSE, TRUE),
    ('underline', 'Whether the span of text should be underlined.', 'BOOLEAN', FALSE, TRUE),
    ('bold', 'Whether the span of text should be displayed as bold.', 'BOOLEAN', FALSE, TRUE),
    ('code', 'Use a monospace font. Useful to display the text as code.', 'BOOLEAN', FALSE, TRUE),
    ('italics', 'Whether the span of text should be displayed as italics.', 'BOOLEAN', FALSE, TRUE),
    ('break', 'Indicates that the current span of text starts a new paragraph.', 'BOOLEAN', FALSE, TRUE),
    ('size', 'A number between 1 and 6 indicating the font size.', 'INTEGER', FALSE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('text', 'Rendering a simple text paragraph.', json('[{"component":"text", "contents":"Hello, world ! <3"}]')),
    ('text', 'Rendering rich text using markdown', json('[{"component":"text", "contents_md":"\n'||
    '# Markdown in SQLPage\n\n' ||
    '## Simple formatting\n\n' ||
    'SQLPage supports only plain text as column values, but markdown allows easily adding **bold**, *italics*, [external links](https://github.com/lovasoa/sqlpage), [links to other pages](/index.sql) and [intra-page links](#my-paragraph). \n\n' ||
    '## Lists\n' ||
    '### Unordered lists\n' ||
    '* SQLPage is easy\n' ||
    '* SQLPage is fun\n' ||
    '* SQLPage is free\n\n' ||
    '### Ordered lists\n' ||
    '1. SQLPage is fast\n' ||
    '2. SQLPage is safe\n' ||
    '3. SQLPage is open-source\n\n' ||
    '## Code\n' ||
    '```sql\n' ||
    'SELECT ''list'' AS component;\n' ||
    'SELECT name as title FROM users;\n' ||
    '```\n\n' ||
    '## Tables\n\n' ||
    '| SQLPage component | Description  | Documentation link  |\n' ||
    '| --- | --- | --- |\n' ||
    '| text | A paragraph of text. | [Documentation](https://sql.ophir.dev/documentation.sql?component=text) |\n' ||
    '| list | A list of items. | [Documentation](https://sql.ophir.dev/documentation.sql?component=list) |\n' ||
    '| steps | A progress indicator. | [Documentation](https://sql.ophir.dev/documentation.sql?component=steps) |\n' ||
    '| form | A series of input fields. | [Documentation](https://sql.ophir.dev/documentation.sql?component=form) |\n\n' ||
    '## Quotes\n' ||
    '> Fantastic.\n>\n' ||
    '> — [HackerNews User](https://news.ycombinator.com/item?id=36194473#36209061) about SQLPage\n\n' ||
    '## Images\n' ||
    '![SQLPage logo](https://sql.ophir.dev/favicon.ico)\n\n' ||
    '## Horizontal rules\n' ||
    '---\n\n' ||
    '"}]')),
    ('text', 'Rendering a paragraph with links and styling.',
            json('[{"component":"text", "title":"About SQL"}, '||
            '{"contents":"SQL", "bold":true, "italics": true}, '||
            '{"contents":" is a domain-specific language used in programming and designed for managing data held in a "},'||
            '{"contents": "relational database management system", "link": "https://en.wikipedia.org/wiki/Relational_database"},'||
            '{"contents": ". It is particularly useful in handling structured data."}]')
    ),
    (
        'text',
        'An intra-page link to a section of the page.',
        json('[
            {"component":"text", "contents_md":"This is a link to the [next paragraph](#my-paragraph). You can open this link in a new tab and the page will scroll to the paragraph on load."},
            {"component":"text", "id": "my-paragraph", "contents_md": "This **is** the next paragraph."}
        ]')
    )
;

INSERT INTO component(name, icon, description) VALUES
    ('form', 'cursor-text', 'A series of input fields that can be filled in by the user. ' ||
    'The form contents can be posted and handled by another sql file in your site. ' ||
    'The value entered by the user in a field named x will be accessible to the target SQL page as a variable named $x.
    For instance, you can create a SQL page named "create_user.sql" that would contain "INSERT INTO users(name) VALUES($name)"
    and a form with its action property set to "create_user.sql" that would contain a field named "name".');
INSERT INTO parameter(component, name, description_md, type, top_level, optional) SELECT 'form', * FROM (VALUES
    -- top level
    ('enctype', '
When ``method="post"``, this specifies how the form-data should be encoded
when submitting it to the server.
', 'TEXT', TRUE, TRUE),
    -- item level
    ('formenctype', '
When ``type`` is ``submit`` or ``image``, this specifies how the form-data
should be encoded when submitting it to the server.

Takes precedence over any ``enctype`` set on the ``form`` element.

NOTE: when a ``file`` type input is present, then ``formenctype="multipart/form-data"``
is automatically applied to the default validate button.
', 'TEXT', FALSE, TRUE)
);
INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'form', * FROM (VALUES
    -- top level
    ('method', 'Set this to ''GET'' to pass the form contents directly as URL parameters. If the user enters a value v in a field named x, submitting the form will load target.sql?x=v. If target.sql contains SELECT $x, it will display the value v.', 'TEXT', TRUE, TRUE),
    ('action', 'An optional link to a target page that will handle the results of the form. By default the target page is the current page with the id of the form (if passed) used as hash - this will bring us back to the location of the form after submission. Setting it to the name of a different sql file will load that file when the user submits the form.', 'TEXT', TRUE, TRUE),
    ('title', 'A name to display at the top of the form. It will be displayed in a larger font size at the top of the form.', 'TEXT', TRUE, TRUE),
    ('validate', 'The text to display in the button at the bottom of the form that submits the values. Omit this property to let the browser display the default form validation text, or set it to the empty string to remove the button completely.', 'TEXT', TRUE, TRUE),
    ('validate_color', 'The color of the button at the bottom of the form that submits the values. Omit this property to use the default color.', 'COLOR', TRUE, TRUE),
    ('validate_outline', 'A color to outline the validation button.', 'COLOR', TRUE, TRUE),
    ('reset', 'The text to display in the button at the bottom of the form that resets the form to its original state. Omit this property not to show a reset button at all.', 'TEXT', TRUE, TRUE),
    ('id', 'A unique identifier for the form, which can then be used to validate the form from a button outside of the form.', 'TEXT', TRUE, TRUE),
    -- item level
    ('type', 'The type of input to use: text for a simple text field, textarea for a multi-line text input control, number to accept only numbers, checkbox or radio for a button that is part of a group specified in the ''name'' parameter, hidden for a value that will be submitted but not shown to the user. text by default.', 'TEXT', FALSE, TRUE),
    ('name', 'The name of the input field, that you can use in the target page to get the value the user entered for the field.', 'TEXT', FALSE, FALSE),
    ('label', 'A friendly name for the text field to show to the user.', 'TEXT', FALSE, TRUE),
    ('placeholder', 'A placeholder text that will be shown in the field when is is empty.', 'TEXT', FALSE, TRUE),
    ('value', 'A default value that will already be present in the field when the user loads the page.', 'TEXT', FALSE, TRUE),
    ('options', 'A json array of objects containing the label and value of all possible options of a select field. Used only when type=select. JSON objects in the array can contain the properties "label", "value" and "selected".', 'JSON', FALSE, TRUE),
    ('required', 'Set this to true to prevent the form contents from being sent if this field is left empty by the user.', 'BOOLEAN', FALSE, TRUE),
    ('min', 'The minimum value to accept for an input of type number', 'REAL', FALSE, TRUE),
    ('max', 'The minimum value to accept for an input of type number', 'REAL', FALSE, TRUE),
    ('checked', 'Used only for checkboxes and radio buttons. Indicates whether the checkbox should appear as already checked.', 'BOOLEAN', FALSE, TRUE),
    ('multiple', 'Used only for select elements. Indicates that multiple elements can be selected simultaneously. When using multiple, you should add square brackets after the variable name: ''my_variable[]'' as name', 'BOOLEAN', FALSE, TRUE),
    ('searchable', 'For select and multiple-select elements, displays them with a nice dropdown that allows searching for options.', 'BOOLEAN', FALSE, TRUE),
    ('dropdown', 'An alias for "searchable".', 'BOOLEAN', FALSE, TRUE),
    ('create_new', 'In a multiselect with a dropdown, this option allows the user to enter new values, that are not in the list of options.', 'BOOLEAN', FALSE, TRUE),
    ('step', 'The increment of values in an input of type number. Set to 1 to allow only integers.', 'REAL', FALSE, TRUE),
    ('description', 'A helper text to display near the input field.', 'TEXT', FALSE, TRUE),
    ('pattern', 'A regular expression that the value must match. For instance, [0-9]{3} will only accept 3 digits.', 'TEXT', FALSE, TRUE),
    ('autofocus', 'Automatically focus the field when the page is loaded', 'BOOLEAN', FALSE, TRUE),
    ('width', 'Width of the form field, between 1 and 12.', 'INTEGER', FALSE, TRUE),
    ('autocomplete', 'Whether the browser should suggest previously entered values for this field.', 'BOOLEAN', FALSE, TRUE),
    ('minlength', 'Minimum length of text allowed in the field.', 'INTEGER', FALSE, TRUE),
    ('maxlength', 'Maximum length of text allowed in the field.', 'INTEGER', FALSE, TRUE),
    ('formaction', 'When type is "submit", this specifies the URL of the file that will handle the form submission. Useful when you need multiple submit buttons.', 'TEXT', FALSE, TRUE),
    ('class', 'A CSS class to apply to the form element.', 'TEXT', FALSE, TRUE),
    ('prefix_icon','Icon to display on the left side of the input field, on the same line.','ICON',FALSE,TRUE),
    ('prefix','Text to display on the left side of the input field, on the same line.','TEXT',FALSE,TRUE),
    ('suffix','Short text to display after th input, on the same line. Useful to add units or a currency symbol to an input.','TEXT',FALSE,TRUE),
    ('readonly','Set to true to prevent the user from modifying the value of the input field.','BOOLEAN',FALSE,TRUE),
    ('disabled','Makes the field non-editable, non-focusable, and not submitted with the form. Use readonly instead for simple non-editable fields.','BOOLEAN',FALSE,TRUE),
    ('id','A unique identifier for the input, which can then be used to select and manage the field with Javascript code. Usefull for advanced using as setting client side event listeners, interactive control of input field (disabled, visibility, read only, e.g.) and AJAX requests.','TEXT',FALSE,TRUE)
) x;
INSERT INTO example(component, description, properties) VALUES
    (
    'form',
    '

The best way to manage forms in SQLPage is to create at least two separate files:

 - one that will contain the form itself, and will be loaded when the user visits the page,
 - one that will handle the form submission, and will redirect to whatever page you want to display after the form has been submitted.

For instance, if you were creating a form to manage a list of users, you could create:

 - a file named `users.sql` that would contain a list of users and a form to create a new user,
 - a file named `create_user.sql` that would insert the new user in the database, and then redirect to `users.sql`.

`create_user.sql` could contain the following sql statement to [safely](safety.sql) insert the new user in the database: 

```sql
INSERT INTO users(name) VALUES(:username)
RETURNING ''redirect'' AS component, ''users.sql'' AS link
```

When loading the page, the value for `:username` will be `NULL` if no value has been submitted.
',
    json('[{"component":"form", "action": "create_user.sql"}, {"name": "username"}]')),
    ('form', 'A user registration form, illustrating the use of required fields, and different input types.', 
    json('[{"component":"form", "title": "User", "validate": "Create new user"}, '||
    '{"name": "First name", "placeholder": "John"}, '||
    '{"name": "Last name", "required": true, "description": "We need your last name for legal purposes."},'||
    '{"name": "Resume", "type": "textarea"},'||
    '{"name": "Birth date", "type": "date", "max": "2010-01-01", "value": "1994-04-16"},'||
    '{"name": "Password", "type": "password", "pattern": "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$", "required": true, "description": "Minimum eight characters, at least one letter and one number."},'||
    '{"label": "I accept the terms and conditions", "name": "terms", "type": "checkbox", "required": true}'||
    ']')),
    ('form','Create prepended and appended inputs to make your forms easier to use.',
    json('[{"component":"form"}, '||
    '{"name": "Your account", "prefix_icon": "mail", "prefix": "Email:", "suffix": "@mydomain.com"}, ' ||
    ']')),
    ('form', 'This example illustrates the use of the `select` type.
In this select input, the various options are hardcoded, but they could also be loaded from a database table,
using a function to convert the rows into a json array like 
 - `json_group_array()` in SQLite,
 - `json_agg()` in Postgres,
 - `JSON_ARRAYAGG()` in MySQL, or
 - `FOR JSON PATH` in Microsoft SQL Server.


In SQLite, the query would look like
```sql
SELECT 
    ''select'' as type,
    json_group_array(json_object(
        "label", name,
        "value", id
    )) as options
FROM fruits
```
', json('[{"component":"form", "action":"examples/show_variables.sql"},
    {"name": "Fruit", "type": "select", "searchable": true, "value": 1, "options":
        "[{\"label\": \"Orange\", \"value\": 0}, {\"label\": \"Apple\", \"value\": 1}, {\"label\": \"Banana\", \"value\": 3}]"}
    ]')),
    ('form', '### Multi-select
You can authorize the user to select multiple options by setting the `multiple` property to `true`.
This creates a more compact (but arguably less user-friendly) alternative to a series of checkboxes.
In this case, you should add square brackets to the name of the field.
The target page will then receive the value as a JSON array of strings, which you can iterate over using 
 - the `json_each` function [in SQLite](https://www.sqlite.org/json1.html) and [Postgres](https://www.postgresql.org/docs/9.3/functions-json.html),
 - the [`OPENJSON`](https://learn.microsoft.com/fr-fr/sql/t-sql/functions/openjson-transact-sql?view=sql-server-ver16) function in Microsoft SQL Server.
 - in MySQL, json manipulation is less straightforward: see [the SQLPage MySQL json example](https://github.com/lovasoa/SQLpage/tree/main/examples/mysql%20json%20handling)

The target page could then look like this:

```sql
insert into best_fruits(id) -- INSERT INTO ... SELECT ... runs the SELECT query and inserts the results into the table
select CAST(value AS integer) as id -- all values are transmitted by the browser as strings
from json_each($preferred_fruits); -- json_each returns a table with a "value" column for each element in the JSON array
```

### Example multiselect generated from a database table

As an example, if you have a table of all possible options (`my_options(id int, label text)`),
and another table that contains the selected options per user (`my_user_options(user_id int, option_id int)`),
you can use a query like this to generate the multi-select field:

```sql
select ''select'' as type, true as multiple, json_group_array(json_object(
    ''label'', my_options.label,
    ''value'', my_options.id,
    ''selected'', my_user_options.option_id is not null
)) as options
from my_options
left join my_user_options
    on  my_options.id = my_user_options.option_id
    and my_user_options.user_id = $user_id
```
', json('[{"component":"form", "action":"examples/show_variables.sql"}, 
    {"label": "Fruits", "name": "fruits[]", "type": "select", "multiple": true, "create_new":true, "placeholder": "Good fruits...", "searchable": true, "description": "press ctrl to select multiple values", "options":
        "[{\"label\": \"Orange\", \"value\": 0, \"selected\": true}, {\"label\": \"Apple\", \"value\": 1}, {\"label\": \"Banana\", \"value\": 3, \"selected\": true}]"}
    ]')),
    ('form', 'This example illustrates the use of the `radio` type.
The `name` parameter is used to group the radio buttons together.
The `value` parameter is used to set the value that will be submitted when the user selects the radio button.
The `label` parameter is used to display a friendly name for the radio button.
The `description` parameter is used to display a helper text near the radio button.

We could also save all the options in a database table, and then run a simple query like

```sql
SELECT ''form'' AS component;
SELECT * FROM fruit_option;
```

In this example, depending on what the user clicks, the target `index.sql` page will be loaded with a the variable `$fruit` set to the string "1", "2", or "3".

    ', json('[{"component":"form", "method": "GET", "action": "index.sql"}, '||
    '{"name": "fruit", "type": "radio", "value": 1, "description": "An apple a day keeps the doctor away", "label": "Apple"}, '||
    '{"name": "fruit", "type": "radio", "value": 2, "description": "Oranges are a good source of vitamin C", "label": "Orange", "checked": true}, '||
    '{"name": "fruit", "type": "radio", "value": 3, "description": "Bananas are a good source of potassium", "label": "Banana"}'||
    ']')),
    ('form', 'When you want to include some information in the form data, but not display it to the user, you can use a hidden field.

This can be used to track simple data such as the current user''s id,
or to implement more complex flows, such as a multi-step form,
where the user is redirected to a different page after each step.

This can also be used to implement [CSRF protection](https://en.wikipedia.org/wiki/Cross-site_request_forgery#Synchronizer_token_pattern),
if your website has authenticated users that can perform sensitive actions through simple links.
But note that SQLPage cookies already have the `SameSite=strict` attribute by default, which protects you against CSRF attacks by default in most cases.

', json('[{"component":"form", "validate": "Delete", "validate_color": "red"}, 
    {"type": "hidden", "name": "resource_id", "value": "1234"},
    {"name": "confirm", "label": "Please type \"sensitive resource\" here to confirm the deletion", "required": true}
    ]')),
    ('form', 'This example illustrates the use of custom validation buttons and half-width fields.',
    json('[{"component":"form", "title": "User", "validate": "Create new user", "validate_color": "green", "reset": "Clear"},
    {"name": "first_name", "label": "First name", "placeholder": "John", "width": 4},
    {"name": "middle_name", "label": "Middle name", "placeholder": "Fitzgerald", "width": 4},
    {"name": "last_name", "label": "Last name", "placeholder": "Doe", "width": 4},
    {"name": "email", "label": "Email", "placeholder": "john.doe@gmail.com", "width": 12},
    {"name": "password", "label": "Password", "type": "password", "width": 6},
    {"name": "password_confirmation", "label": "Password confirmation", "type": "password", "width": 6},
    {"name": "terms", "label": "I accept the terms and conditions", "type": "checkbox", "required": true}
    ]')),
    ('form', '
## File upload

You can use the `file` type to allow the user to upload a file.

The file will be uploaded to the server, and you will be able to access it using the
[`sqlpage.uploaded_file_path`](functions.sql?function=uploaded_file_path#function) function.

Here is how you could save the uploaded file to a table in the database:

```sql
INSERT INTO uploaded_file(name, data) VALUES(:filename, sqlpage.uploaded_file_data_url(:filename))
```
',
    json('[{"component":"form", "enctype": "multipart/form-data", "title": "Upload a picture", "validate": "Upload", "action": "examples/handle_picture_upload.sql"}, 
    {"name": "my_file", "type": "file", "accept": "image/png, image/jpeg",  "label": "Picture", "description": "Upload a small picture", "required": true}
    ]')),
    ('form', '
## Form Encoding

You can specify the way form data should be encoded by setting the `enctype`
top-level property on the form.

You may also specify `formenctype` on `submit` and `image` type inputs.
This will take precedence over the `enctype` specified on the form and is
useful in the case there are multiple `submit` buttons on the form.
For example, an external site may have specific requirements on encoding type.

As a rule of thumb, ``multipart/form-data`` is best when fields may contain
copious non-ascii characters or for binary data such as an image or a file.
However, ``application/x-www-form-urlencoded`` creates less overhead when
many short ascii text values are submitted.
',
    json('[
  {
    "component": "form",
    "method": "post",
    "enctype": "multipart/form-data",
    "title": "Submit with different encoding types",
    "validate": "Submit with form encoding type",
    "action": "examples/handle_enctype.sql"
  },
  {"name": "data", "type": "text", "label": "Data", "required": true},
  {
    "name": "percent_encoded",
    "type": "submit",
    "label": "Submit as",
    "width": 4,
    "formaction": "examples/handle_enctype.sql",
    "formenctype": "application/x-www-form-urlencoded",
    "value": "application/x-www-form-urlencoded"
  },
  {
    "name": "multipart_form_data",
    "type": "submit",
    "label": "Submit as",
    "width": 4,
    "formaction": "examples/handle_enctype.sql",
    "formenctype": "multipart/form-data",
    "value": "multipart/form-data"
  }
]')),
    ('form', '
## Bulk data insertion

You can use the `file` type to allow the user to upload a [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) 
file containing data to insert in a table.

SQLPage can load data from a CSV file and insert it into a database table.
SQLPage re-uses PostgreSQL''s [`COPY` syntax](https://www.postgresql.org/docs/current/sql-copy.html)
to specify the format of the CSV file, but makes it work with all supported databases.

> When connected to a PostgreSQL database, SQLPage will use the native `COPY` statement,
> for super fast and efficient on-database CSV parsing.
> But it will also work transparently with other databases, by
> parsing the CSV locally and emulating the same behavior with simple `INSERT` statements.

Here is how you could easily copy data from a CSV to a table in the database:

```sql
copy product(name, description) from ''product_data_input''
with (header true, delimiter '','', quote ''"'');
```

If you want to pre-process the data before inserting it into the final table,
you can use a temporary table to store the data, and then insert it into the final table:

```sql
-- temporarily store the data in a table with text columns
create temporary table if not exists product_tmp(name text, description text, price text);
delete from product_tmp;

-- copy the data from the CSV file into the temporary table
copy product_tmp(name, description, price) from ''product_data_input'';

-- insert the data into the final table, converting the price column to an integer
insert into product(name, description, price)
select name, description, CAST(price AS integer) from product_tmp
where price is not null and description is not null and length(description) > 10;
```

This will load the processed CSV into the product table, provided it has the following structure:

```csv
name,description,price
"SQLPage","A tool to create websites using SQL",0
"PostgreSQL","A powerful open-source relational database",0
"SQLite","A lightweight relational database",0
"MySQL","A popular open-source relational database",0
```
',
    json('[{"component":"form", "title": "CSV import", "validate": "Load data", "action": "examples/handle_csv_upload.sql"}, 
    {"name": "product_data_input", "type": "file", "accept": "text/csv",  "label": "Products", "description": "Upload a CSV with a name, description, and price columns", "required": true}
    ]'))
;

INSERT INTO component(name, icon, description) VALUES
    ('chart', 'timeline', 'A component that plots data. Line, area, bar, and pie charts are all supported. Each item in the component is a data point in the graph.');

INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'chart', * FROM (VALUES
    -- top level
    ('title', 'The name of the chart.', 'TEXT', TRUE, TRUE),
    ('type', 'The type of chart: "line", "area", "bar", "column", "pie", "scatter", "bubble", or "heatmap".', 'TEXT', TRUE, FALSE),
    ('time', 'Whether the x-axis represents time. If set to true, the x values will be parsed and formatted as dates for the user.', 'BOOLEAN', TRUE, TRUE),
    ('ymin', 'The minimal value for the y-axis.', 'REAL', TRUE, TRUE),
    ('ymax', 'The maximum value for the y-axis.', 'REAL', TRUE, TRUE),
    ('xtitle', 'Title of the x axis, displayed below it.', 'TEXT', TRUE, TRUE),
    ('ytitle', 'Title of the y axis, displayed to its left.', 'TEXT', TRUE, TRUE),
    ('ztitle', 'Title of the z axis, displayed in tooltips.', 'TEXT', TRUE, TRUE),
    ('xticks', 'Number of ticks on the x axis.', 'INTEGER', TRUE, TRUE),
    ('ystep', 'Step between ticks on the y axis.', 'REAL', TRUE, TRUE),
    ('marker', 'Marker size', 'REAL', TRUE, TRUE),
    ('labels', 'Whether to show the data labels on the chart or not.', 'BOOLEAN', TRUE, TRUE),
    ('color', 'The name of a color in which to display the chart. If there are multiple series in the chart, this parameter can be repeated multiple times.', 'COLOR', TRUE, TRUE),
    ('stacked', 'Whether to cumulate values from different series.', 'BOOLEAN', TRUE, TRUE),
    ('toolbar', 'Whether to display a toolbar at the top right of the chart, that offers downloading the data as CSV.', 'BOOLEAN', TRUE, TRUE),
    ('logarithmic', 'Display the y-axis in logarithmic scale.', 'BOOLEAN', TRUE, TRUE),
    ('horizontal', 'Displays a bar chart with horizontal bars instead of vertical ones.', 'BOOLEAN', TRUE, TRUE),
    ('height', 'Height of the chart, in pixels. By default: 250', 'INTEGER', TRUE, TRUE),
    -- item level
    ('x', 'The value of the point on the horizontal axis', 'REAL', FALSE, FALSE),
    ('y', 'The value of the point on the vertical axis', 'REAL', FALSE, FALSE),
    ('label', 'An alias for parameter "x"', 'REAL', FALSE, TRUE),
    ('value', 'An alias for parameter "y"', 'REAL', FALSE, TRUE),
    ('series', 'If multiple series are represented and share the same y-axis, this parameter can be used to distinguish between them.', 'TEXT', FALSE, TRUE)
) x;
INSERT INTO example(component, description, properties) VALUES
    ('chart', 'An area chart representing a time series, using the top-level property `time`.
    Ticks on the x axis are adjusted automatically, and ISO datetimes are parsed and displayed in a readable format.', json('[
    {
        "component": "chart",
        "title": "Quarterly Revenue",
        "type": "area",
        "color": "indigo",
        "marker": 5,
        "time": true
    },
        {"x":"2022-01-01T00:00:00Z","y":15},
        {"x":"2022-04-01T00:00:00Z","y":46},
        {"x":"2022-07-01T00:00:00Z","y":23},
        {"x":"2022-10-01T00:00:00Z","y":70},
        {"x":"2023-01-01T00:00:00Z","y":35},
        {"x":"2023-04-01T00:00:00Z","y":106},
        {"x":"2023-07-01T00:00:00Z","y":53}
    ]')),
    ('chart', 'A pie chart.', json('[{"component":"chart", "title": "Answers", "type": "pie", "labels": true}, '||
    '{"label": "Yes", "value": 65}, '||
    '{"label": "No", "value": 35}]')),
    ('chart', 'A basic bar chart', json('[{"component":"chart", "type": "bar", "title": "Quarterly Results", "horizontal": true}, '||
    '{"label": "Tom", "value": 35}, {"label": "Olive", "value": 15}]')),
    ('chart', 'A bar chart with multiple series.', json('[{"component":"chart", "title": "Expenses", "type": "bar", "stacked": true, "toolbar": true, "ystep": 10}, '||
    '{"series": "Marketing", "x": 2021, "value": 35}, '||
    '{"series": "Marketing", "x": 2022, "value": 15}, '||
    '{"series": "Human resources", "x": 2021, "value": 30}, '||
    '{"series": "Human resources", "x": 2022, "value": 55}]')),
    ('chart', 'A line chart with multiple series.', json('[{"component":"chart", "title": "Revenue", "ymin": 0},
    {"series": "Chicago Store", "x": 2021, "value": 35}, 
    {"series": "Chicago Store", "x": 2022, "value": 15}, 
    {"series": "Chicago Store", "x": 2023, "value": 45}, 
    {"series": "New York Store", "x": 2021, "value": 30}, 
    {"series": "New York Store", "x": 2022, "value": 55},
    {"series": "New York Store", "x": 2023, "value": 19}
    ]')),
    ('chart', 'A scatter plot with multiple custom options.',
    json('[
        {"component":"chart", "title": "Gross domestic product and its growth", "type": "scatter",
        "xtitle": "Growth Rate", "ytitle": "GDP (Trillions USD)", "height": 500, "marker": 8,
        "xmin": 0, "xmax": 10, "ymin": 0, "ymax": 25, "yticks": 5},

        {"series": "Brazil", "x": 2.5, "y": 2},
        {"series": "China", "x": 6.5, "y": 14},
        {"series": "United States", "x": 2.3, "y": 21},
        {"series": "France", "x": 1.5, "y": 3},
        {"series": "South Africa", "x": 0.9, "y": 0.3}
    ]')),
    ('chart', '
## Heatmaps

You can build heatmaps using the `heatmap` top-level property.

The data format follows the [apexcharts heatmap format](https://apexcharts.com/angular-chart-demos/heatmap-charts/basic/),
where each series is represented as a line in the chart:
 - The `x` property of each item will be used as the x-axis value.
 - The `series` property of each item will be used as the y-axis value.
 - The `y` property of each item will be used as the value to display in the heatmap

The `color` property sets the color of each series separately, in order.
',json('[
        {"component":"chart", "title": "Survey Results", "type": "heatmap",
        "ytitle": "Database managemet system", "xtitle": "Year", "color": ["red","orange","yellow"]},
        { "series": "PostgreSQL", "x": "2000", "y": 48},{ "series": "SQLite", "x": "2000", "y": 14},{ "series": "MySQL", "x": "2000", "y": 78},
        { "series": "PostgreSQL", "x": "2010", "y": 65},{ "series": "SQLite", "x": "2010", "y": 22},{ "series": "MySQL", "x": "2010", "y": 83},
        { "series": "PostgreSQL", "x": "2020", "y": 73},{ "series": "SQLite", "x": "2020", "y": 28},{ "series": "MySQL", "x": "2020", "y": 87}
      ]')),
    ('chart', '
## Multiple charts on the same line

You can create information-dense dashboards by using the [card component](?component=card#component)
to put multiple charts on the same line.

For this, create one sql file per visualization you want to show,
and set the `embed` attribute of the [card](?component=card#component) component
to the path of the file you want to include, followed by `?_sqlpage_embed`.
',
        json('[
            {"component":"card", "title":"A dashboard with multiple graphs on the same line", "columns": 2},
            {"embed": "/examples/chart.sql?color=green&n=42&_sqlpage_embed", "footer_md": "You can find the sql file that generates the chart [here](https://github.com/lovasoa/SQLpage/tree/main/examples/official-site/examples/chart.sql)" },
            {"embed": "/examples/chart.sql?_sqlpage_embed" },
        ]'));

INSERT INTO component(name, icon, description) VALUES
    ('table', 'table', 'A table with optional filtering and sorting.
Unlike most others, this component does not have a fixed set of item properties, any property that is used will be rendered directly as a column in the table.
Tables can contain rich text, including images, links, and icons. Table rows can be styled with a background color, and the table can be made striped, hoverable, and bordered.

Advanced users can apply custom styles to table columns using a CSS class with the same name as the column, and to table rows using the `_sqlpage_css_class` property.
');

INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'table', * FROM (VALUES
    -- top level
    ('sort', 'Make the columns clickable to let the user sort by the value contained in the column.', 'BOOLEAN', TRUE, TRUE),
    ('search', 'Add a search bar at the top of the table, letting users easily filter table rows by value.', 'BOOLEAN', TRUE, TRUE),
    ('markdown', 'Set this to the name of a column whose content should be interpreted as markdown . Used to display rich text with links in the table. This argument can be repeated multiple times to intepret multiple columns as markdown.', 'TEXT', TRUE, TRUE),
    ('icon', 'Set this to the name of a column whose content should be interpreted as a tabler icon name. Used to display icons in the table. This argument can be repeated multiple times to intepret multiple columns as icons. Introduced in v0.8.0.', 'TEXT', TRUE, TRUE),
    ('align_right', 'Name of a column the contents of which should be right-aligned. This argument can be repeated multiple times to align multiple columns to the right. Introduced in v0.15.0.', 'TEXT', TRUE, TRUE),
    ('striped_rows', 'Whether to add zebra-striping to any table row.', 'BOOLEAN', TRUE, TRUE),
    ('striped_columns', 'Whether to add zebra-striping to any table column.', 'BOOLEAN', TRUE, TRUE),
    ('hover', 'Whether to enable a hover state on table rows.', 'BOOLEAN', TRUE, TRUE),
    ('border', 'Whether to draw borders on all sides of the table and cells.', 'BOOLEAN', TRUE, TRUE),
    ('overflow', 'Whether to to let "wide" tables overflow across the right border and enable browser-based horizontal scrolling.', 'BOOLEAN', TRUE, TRUE),
    ('small', 'Whether to use compact table.', 'BOOLEAN', TRUE, TRUE),
    ('description','Description of the table content and helps users with screen readers to find a table and understand what it’s.','TEXT',TRUE,TRUE),
    -- row level
    ('_sqlpage_css_class', 'For advanced users. Sets a css class on the table row. Added in v0.8.0.', 'TEXT', FALSE, TRUE),
    ('_sqlpage_color', 'Sets the background color of the row. Added in v0.8.0.', 'TEXT', FALSE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('table', 'The most basic table.',
        json('[{"component":"table"}, {"a": 1, "b": 2}, {"a": 3, "b": 4}]')),
    ('table', 'A table of users with filtering and sorting.',
        json('[{"component":"table", "sort":true, "search":true}, '||
        '{"Forename": "Ophir", "Surname": "Lojkine", "Pseudonym": "lovasoa"},' ||
        '{"Forename": "Linus", "Surname": "Torvalds", "Pseudonym": "torvalds"}]')),
    ('table', 'A table that uses markdown to display links',
        json('[{"component":"table", "markdown": "Documentation", "icon": "icon", "sort": true, "search": true}, '||
        '{"icon": "table", "name": "Table", "description": "Displays SQL results as a searchable table.", "Documentation": "[docs](documentation.sql?component=table)", "_sqlpage_color": "red"},
        {"icon": "timeline", "name": "Chart", "description": "Show graphs based on numeric data.", "Documentation": "[docs](documentation.sql?component=chart)"}
        ]')),
    (
    'table',
    'A table with numbers',
    json(
        '[{"component":"table", "search": true, "sort": true, "align_right": ["Price ($)", "Amount in stock"]}, ' ||
         '{"id": 31456, "part_no": "MIC-ROCC-F-23-206-C", "Price ($)": 12, "Amount in stock": 5},
          {"id": 996, "part_no": "MIC-ROCC-F-24-206-A", "Price ($)": 1, "Amount in stock": 15},
          {"id": 131456, "part_no": "KIB-ROCC-F-13-205-B", "Price ($)": 127, "Amount in stock": 9}
        ]'
    )),
    (
    'table',
    'A table with some presentation options',
    json(
        '[{"component":"table", "hover": true, "striped_rows": true, "description": "Some Star Trek Starfleet starships", "small": true},'||
        '{"name": "USS Enterprise", "registry": "NCC-1701-C", "class":"Ambassador"},
         {"name": "USS Archer", "registry": "NCC-44278", "class":"Archer"},
         {"name": "USS Endeavour", "registry": "NCC-06", "class":"Columbia"},
         {"name": "USS Constellation", "registry": "NCC-1974", "class":"Constellation"},
         {"name": "USS Dakota", "registry": "NCC-63892", "class":"Akira"}
        ]'
    )
    );


INSERT INTO component(name, icon, description) VALUES
    ('csv', 'download', 'A button that lets the user download data as a CSV file. Each column from the items in the component will map to a column in the resulting CSV.');

INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'csv', * FROM (VALUES
    -- top level
    ('separator', 'How individual values should be separated in the CSV. "," by default, set it to "\t" for tab-separated values.', 'TEXT', TRUE, TRUE),
    ('title', 'The text displayed on the download button.', 'TEXT', TRUE, FALSE),
    ('filename', 'The name of the file that should be downloaded (without the extension).', 'TEXT', TRUE, TRUE),
    ('icon', 'Name of the icon (from tabler-icons.io) to display in the button.', 'ICON', TRUE, TRUE),
    ('color', 'Color of the button', 'COLOR', TRUE, TRUE),
    ('size', 'The size of the button (e.g., sm, lg).', 'TEXT', TRUE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('csv', 'CSV download button',
        json('[{"component":"csv", "title": "Download my data", "filename": "people", "icon": "file-download", "color": "green", "separator": ";"}, '||
        '{"Forename": "Ophir", "Surname": "Lojkine", "Pseudonym": "lovasoa"},' ||
        '{"Forename": "Linus", "Surname": "Torvalds", "Pseudonym": "torvalds"}]'));


INSERT INTO component(name, icon, description) VALUES
    ('dynamic', 'repeat', 'A special component that can be used to render other components, the number and properties of which are not known in advance.');

INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'dynamic', * FROM (VALUES
    -- top level
    ('properties', 'A json object or array that contains the names and properties of other components', 'JSON', TRUE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('dynamic', 'Rendering a text paragraph dynamically.', json('[{"component":"dynamic", "properties": "[{\"component\":\"text\"}, {\"contents\":\"Blah\", \"bold\":true}]"}]')),
    ('dynamic', '
## Dynamic shell

On databases without a native JSON type (such as the default SQLite database),
you can use the `dynamic` component to generate
json data to pass to components that expect it.

This example generates a menu similar to the [shell example](?component=shell#component), but without using a native JSON type.

```sql
SELECT ''dynamic'' AS component, json_object(
    ''component'', ''shell'',
    ''title'', ''SQLPage documentation'',
    ''link'', ''/'',
    ''menu_item'', json_array(
        json_object(
            ''link'', ''index.sql'',
            ''title'', ''Home''
        ),
        json_object(
            ''title'', ''Community'',
            ''submenu'', json_array(
                json_object(
                    ''link'', ''blog.sql'',
                    ''title'', ''Blog''
                ),
                json_object(
                    ''link'', ''//github.com/lovasoa/sqlpage/issues'',
                    ''title'', ''Issues''
                ),
                json_object(
                    ''link'', ''//github.com/lovasoa/sqlpage/discussions'',
                    ''title'', ''Discussions''
                ),
                json_object(
                    ''link'', ''//github.com/lovasoa/sqlpage'',
                    ''title'', ''Github''
                )
            )
        )
    )
) AS properties
```

[View the result of this query, as well as an example of how to generate a dynamic menu
based on the database contents](./examples/dynamic_shell.sql).
', NULL),
    ('dynamic', '
## Static component data stored in `.json` files

You can also store the data for a component in a `.json` file, and load it using the `dynamic` component.

This can be useful to store the data for a component in a separate file,
shared between multiple pages,
and avoid having to escape quotes in SQL strings.

For instance, the following query will load the data for a `shell` component from the file `shell.json`:

```sql
SELECT ''dynamic'' AS component, sqlpage.read_file_as_text(''shell.json'') AS properties;
```

and `shell.json` would be placed at the website''s root and contain the following:

```json
{
    "component": "shell",
    "title": "SQLPage documentation",
    "link": "/",
    "menu_item": [
        {"link": "index.sql", "title": "Home"},
        {"title": "Community", "submenu": [
            {"link": "blog.sql", "title": "Blog"},
            {"link": "https//github.com/lovasoa/sqlpage/issues", "title": "Issues"},
            {"link": "https//github.com/lovasoa/sqlpage/discussions", "title": "Discussions"},
            {"link": "https//github.com/lovasoa/sqlpage", "title": "Github"}
        ]}
    ]
}
```
', NULL);

INSERT INTO component(name, icon, description, introduced_in_version) VALUES
    ('loader-start', 'refresh', 'Display a spinner to indicate page is loading.', '0.25.0');

INSERT INTO parameter(component, name, description_md, type, top_level, optional) SELECT 'loader-start', * FROM (VALUES
    ('spinner', '
The name of a [spinner](https://tabler.io/docs/components/spinners) (from tabler.io).
Default is "spinner-border".
Set to the empty string to disable the spinner - e.g. to display only progress
updates.
', 'TEXT', TRUE, TRUE),
    ('size', 'Size of the spinner (e.g. sm, lg) [see here](https://tabler.io/docs/components/progress)', 'TEXT', TRUE, TRUE),
    ('color', 'Color of the spinner', 'COLOR', TRUE, TRUE)
) x;

INSERT INTO component(name, icon, description, introduced_in_version) VALUES
    ('loader-stop', 'refresh-off', '
Hide the spinner displayed by the loader-start component.
', '0.25.0');

INSERT INTO component(name, icon, description, introduced_in_version) VALUES
    ('progress', 'time-duration-15', 'Display a progress bar.', '0.25.0');

INSERT INTO parameter(component, name, description_md, type, top_level, optional) SELECT 'progress', * FROM (VALUES
    -- top-level
    ('percent', 'Number between 0 and 100.', 'INTEGER', TRUE, TRUE),
    ('stage', 'A message to display under the progress bar to indicate which stage the process is at.', 'TEXT', TRUE, TRUE),
    ('color', 'The fill color of the progress bar', 'COLOR', TRUE, TRUE),
    ('size', 'The size of the progress bar (e.g. sm, lg) [see here](https://tabler.io/docs/components/progress)', 'TEXT', TRUE, TRUE),
    -- item-level
    ('percent', 'Number between 0 and 100.', 'INTEGER', FALSE, TRUE),
    ('stage', 'A message to display under the progress bar to indicate which stage the process is at.', 'TEXT', FALSE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('loader-start', '
Will be displayed until [loader-stop](/documentation.sql?component=loader-stop) is selected.

See the [live example](/examples/show-progress/).

Source is [here](https://github.com/lovasoa/SQLpage/tree/main/examples/official-site/examples/show-progress)
', NULL),
    ('loader-stop', '
Hide the spinner displayed by the [loader-start](/documentation.sql?component=loader-start) component.

See the [live example](/examples/show-progress/).

Source is [here](https://github.com/lovasoa/SQLpage/tree/main/examples/official-site/examples/show-progress)
', NULL),
    ('progress', '
Can be used on it''s own (will persist on the page) or with
[loader-start](/documentation.sql?component=loader-start) and
[loader-stop](/documentation.sql?component=loader-stop) to hide the progress bar once processing
is complete.

Subsequent uses of this component and/or any rows will
update the progress bar.

See the [live example](/examples/show-progress/).

Source is [here](https://github.com/lovasoa/SQLpage/tree/main/examples/official-site/examples/show-progress)
', NULL)
;

INSERT INTO component(name, icon, description) VALUES
    ('shell', 'layout-navbar', 'Personalize the "shell" surrounding your page contents. Used to set properties for the entire page.');

INSERT INTO parameter(component, name, description_md, type, top_level, optional) SELECT 'shell', * FROM (VALUES
    ('favicon', 'The URL of the icon the web browser should display in bookmarks and tabs. This property is particularly useful if multiple sites are hosted on the same domain with different [``site_prefix``](https://github.com/lovasoa/SQLpage/blob/main/configuration.md#configuring-sqlpage).', 'URL', TRUE, TRUE),
    ('manifest', 'The location of the [manifest.json](https://developer.mozilla.org/en-US/docs/Web/Manifest) if the site is a [PWA](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps). Among other features, serving a manifest enables your site to be "installed" as an app on most mobile devices.', 'URL', TRUE, TRUE)
) x;
INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'shell', * FROM (VALUES
    -- top level
    ('title', 'The title of your page. Will be shown in a top bar above the page contents. Also usually displayed by web browsers as the name of the web page''s tab.', 'TEXT', TRUE, TRUE),
    ('layout', 'The general page layout. Can be "boxed" (the default), "horizontal" (for a full-width menu), "vertical"(vertical menu), "fluid" (removes side margins).', 'TEXT', TRUE, TRUE),
    ('description', 'A description of the page. It can be displayed by search engines when your page appears in their results.', 'TEXT', TRUE, TRUE),
    ('link', 'The target of the link in the top navigation bar.', 'URL', TRUE, TRUE),
    ('css', 'The URL of a CSS file to load and apply to the page.', 'URL', TRUE, TRUE),
    ('javascript', 'The URL of a Javascript file to load and execute on the page.', 'URL', TRUE, TRUE),
    ('rss', 'The URL of an RSS feed to display in the top navigation bar. You can use the rss component to generate the field.', 'URL', TRUE, TRUE),
    ('image', 'The URL of an image to display next to the page title.', 'URL', TRUE, TRUE),
    ('social_image', 'The URL of the preview image that will appear in the Open Graph metadata when the page is shared on social media.', 'URL', TRUE, TRUE),
    ('icon', 'Name of an icon (from tabler-icons.io) to display next to the title in the navigation bar.', 'ICON', TRUE, TRUE),
    ('menu_item', 'Adds a menu item in the navigation bar at the top of the page. The menu item will have the specified name, and will link to as .sql file of the same name. A dropdown can be generated by passing a json object with a `title` and `submenu` properties.', 'TEXT', TRUE, TRUE),
    ('fixed_top_menu', 'Fixes the top bar with menu at the top (the top bar remains visible when scrolling long pages).', 'BOOLEAN', TRUE, TRUE),
    ('search_target', 'When this is set, a search field will appear in the top navigation bar, and load the specified sql file with an URL parameter named "search" when the user searches something.', 'TEXT', TRUE, TRUE),
    ('search_value', 'This value will be placed in the search field when "search_target" is set. Using the "$search" query parameter value will mirror the value that the user has searched for.', 'TEXT', TRUE, TRUE),
    ('norobot', 'Forbids robots to save this page in their database and follow the links on this page. This will prevent this page to appear in Google search results for any query, for instance.', 'BOOLEAN', TRUE, TRUE),
    ('font', 'Specifies the font to be used for displaying text, which can be a valid font name from fonts.google.com or the path to a local WOFF2 font file starting with a slash (e.g., "/fonts/MyLocalFont.woff2").', 'TEXT', TRUE, TRUE),
    ('font_size', 'Font size on the page, in pixels. Set to 18 by default.', 'INTEGER', TRUE, TRUE),
    ('language', 'The language of the page. This can be used by search engines and screen readers to determine in which language the page is written.', 'TEXT', TRUE, TRUE),
    ('refresh', 'Number of seconds after which the page should refresh. This can be useful to display dynamic content that updates automatically.', 'INTEGER', TRUE, TRUE),
    ('theme', 'Set to "dark" to use a dark theme.', 'TEXT', TRUE, TRUE),
    ('footer', 'Muted text to display in the footer of the page. This can be used to display a link to the terms and conditions of your application, for instance. By default, shows "Built with SQLPage". Supports links with markdown.', 'TEXT', TRUE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('shell', '
This example contains the values used for the shell of the page you are currently viewing.

The `menu_item` property is used both in its simple string form, to generate a link named "functions" that points to "functions.sql",
and in its object form, to generate a dropdown menu named "Community" with links to the blog, the github repository, and the issues page.

The object form can be used directly only on database engines that have a native JSON type.
On other engines (such as SQLite), you can use the [`dynamic`](?component=dynamic#component) component to generate the same result.

You see the [page layouts demo](./examples/layouts.sql) for a live example of the different layouts.
',
     json('[{
            "component": "shell",
            "title": "SQLPage",
            "icon": "database",
            "link": "/",
            "menu_item": [
                {"title": "About", "submenu": [
                    {"link": "/safety.sql", "title": "Security", "icon": "lock"},
                    {"link": "/performance.sql", "title": "Performance", "icon": "bolt"},
                    {"link": "//github.com/lovasoa/SQLpage/blob/main/LICENSE.txt", "title": "License", "icon": "file-text"},
                    {"link": "/blog.sql", "title": "Articles", "icon": "book"}
                ]},
                {"title": "Examples", "submenu": [
                    {"link": "/examples/tabs.sql", "title": "Tabs", "icon": "layout-navbar"},
                    {"link": "/examples/layouts.sql", "title": "Layouts", "icon": "layout"},
                    {"link": "/examples/multistep-form", "title": "Forms", "icon": "edit"},
                    {"link": "/examples/handle_picture_upload.sql", "title": "File uploads", "icon": "upload"},
                    {"link": "/examples/authentication/", "title": "Password protection", "icon": "password-user"},
                    {"link": "/examples/show-progress/", "title": "Tracking progress of background tasks", "icon": "loader-2"},
                    {"link": "//github.com/lovasoa/SQLpage/blob/main/examples/", "title": "All examples & demos", "icon": "code"}
                ]},
                {"title": "Community", "submenu": [
                    {"link": "blog.sql", "title": "Blog", "icon": "book"},
                    {"link": "//github.com/lovasoa/sqlpage/issues", "title": "Report a bug", "icon": "bug"},
                    {"link": "//github.com/lovasoa/sqlpage/discussions", "title": "Discussions", "icon": "message"},
                    {"link": "//github.com/lovasoa/sqlpage", "title": "Github", "icon": "brand-github"}
                ]},
                {"title": "Documentation", "submenu": [
                    {"link": "/your-first-sql-website", "title": "Getting started", "icon": "book"},
                    {"link": "/components.sql", "title": "All Components", "icon": "list-details"},
                    {"link": "/functions.sql", "title": "SQLPage Functions", "icon": "math-function"},
                    {"link": "/custom_components.sql", "title": "Custom Components", "icon": "puzzle"},
                    {"link": "//github.com/lovasoa/SQLpage/blob/main/configuration.md#configuring-sqlpage", "title": "Configuration", "icon": "settings"}
                ]}
            ],
            "layout": "boxed",
            "language": "en-US",
            "description": "Documentation for the SQLPage low-code web application framework.",
            "font": "Poppins",
            "javascript": ["https://cdn.jsdelivr.net/npm/prismjs@1/components/prism-core.min.js", 
                           "https://cdn.jsdelivr.net/npm/prismjs@1/plugins/autoloader/prism-autoloader.min.js"],
            "css": "/prism-tabler-theme.css",
            "footer": "Official [SQLPage](https://sql.ophir.dev) documentation"
        }]')),
    ('shell', '
### Sharing the shell between multiple pages

It is common to want to share the same shell between multiple pages.

#### Static menu

If your menu is completely static (it does not depend on the database content),
you can use the [`dynamic`](?component=dynamic#component) component together with the 
[`sqlpage.read_file_as_text`](functions.sql?function=read_file_as_text#function) function to load the shell from
a json file.

```sql
SELECT ''dynamic'' AS component, sqlpage.read_file_as_text(''shell.json'') AS properties;
```

and in `shell.json`:

```json
{
    "component": "shell",
    "title": "SQL + JSON = <3",
    "link": "/",
    "menu_item": [
        {"link": "index.sql", "title": "Home"},
        {"title": "Community", "submenu": [
            {"link": "blog.sql", "title": "Blog"},
            {"link": "//github.com/lovasoa/sqlpage", "title": "Github"}
        ]}
    ]
}
```

#### Dynamic menu

If your menu depends on the database content, or on special `sqlpage` functions,
you can use the `dynamic` component,
but this time with the [`sqlpage.run_sql`](functions.sql?function=run_sql#function)
function to generate the menu from the database.

```sql
SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell.sql'') AS properties;
```

and in `shell.sql`:

```sql
SELECT ''shell'' AS component, ''run_sql is cool'' as title,
    json_group_array(json_object(
        ''link'', link,
        ''title'', title
    )) as menu_item
FROM my_menu_items
```

(check your database documentation for the exact syntax of the `json_group_array` function).

Another case when dynamic menus are useful is when you want to show some
menu items only in certain conditions.

For instance, you could show an "Admin panel" menu item only to users with the "admin" role,
a "Profile" menu item only to authenticated users,
and a "Login" menu item only to unauthenticated users:

```sql
SET $role = (
    SELECT role FROM users
    INNER JOIN sessions ON users.id = sessions.user_id
    WHERE sessions.session_id = sqlpage.cookie(''session_id'')
); -- Read more about how to handle user sessions in the "authentication" component documentation

SELECT 
    ''shell'' AS component,
    ''My authenticated website'' AS title,

    -- Add an admin panel link if the user is an admin
    CASE WHEN $role = ''admin'' THEN ''{"link": "admin.sql", "title": "Admin panel"}'' END AS menu_item,

    -- Add a profile page if the user is authenticated
    CASE WHEN $role IS NOT NULL THEN ''{"link": "profile.sql", "title": "My profile"}'' END AS menu_item,

    -- Add a login link if the user is not authenticated
    CASE WHEN $role IS NULL THEN ''login'' END AS menu_item
;
```

More about how to handle user sessions in the [authentication component documentation](?component=authentication#component).

### Menu with icons

The "icon" attribute may be specified for items in the top menu and submenus to display an icon
before the title (or instead). Similarly, the "image" attribute defines a file-based icon. For
image-based icons, the "size" attribute may be specified at the top level of menu_item only to
reduce the size of image-based icons. The following snippet provides an example, which is also
available [here](examples/menu_icon.sql).

```sql
SELECT 
    ''shell''             AS component,
    ''SQLPage''           AS title,
    ''database''          AS icon,
    ''/''                 AS link,
    TRUE                AS fixed_top_menu,
    ''{"title":"About","icon": "settings","submenu":[{"link":"/safety.sql","title":"Security","icon": "logout"},{"link":"/performance.sql","title":"Performance"}]}'' AS menu_item,
    ''{"title":"Examples","image": "https://upload.wikimedia.org/wikipedia/en/6/6b/Terrestrial_globe.svg","submenu":[{"link":"/examples/tabs.sql","title":"Tabs","image": "https://upload.wikimedia.org/wikipedia/en/6/6b/Terrestrial_globe.svg"},{"link":"/examples/layouts.sql","title":"Layouts"}]}'' AS menu_item,
    ''{"title":"Examples","size":"sm","image": "https://upload.wikimedia.org/wikipedia/en/6/6b/Terrestrial_globe.svg","submenu":[{"link":"/examples/tabs.sql","title":"Tabs","image": "https://upload.wikimedia.org/wikipedia/en/6/6b/Terrestrial_globe.svg"},{"link":"/examples/layouts.sql","title":"Layouts"}]}'' AS menu_item,
    ''Official [SQLPage](https://sql.ophir.dev) documentation'' as footer;
```
', NULL),
    ('shell', '
### A page without a shell
SQLPage provides the `shell-empty` component to create a page without a shell.
In this case, the `html` and `body` tags are not generated, and the components are rendered directly in the page
without any styling, navigation bar, footer, or dynamic content.
This is useful when you want to generate a snippet of HTML that can be dynamically included in a larger page.

Any component whose name starts with `shell` will be considered as a shell component,
so you can also [create your own shell component](custom_components.sql#custom-shell).

If you generate your own HTML from a SQL query, you can also use the `shell-empty` component to include it in a page.
Make sure you know what you are doing, and be careful to escape the HTML properly,
as you are stepping out of the safe SQLPage framework and into the wild world of HTML.',
    json('[{"component":"shell-empty", "html": "<!DOCTYPE html>\n<html>\n<head>\n  <title>My page</title>\n</head>\n<body>\n  <h1>My page</h1>\n</body>\n</html>"}]'));
