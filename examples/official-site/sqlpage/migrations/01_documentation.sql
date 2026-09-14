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
    ('description_md', 'A description of the list item, displayed as greyed-out text, in Markdown format, allowing you to use rich text formatting, including `**bold**` and `*italic*` text.', 'TEXT', FALSE, TRUE),
    ('link', 'An URL to which the user should be taken when they click on the list item.', 'URL', FALSE, TRUE),
    ('icon', 'Name of an icon to display on the left side of the item.', 'ICON', FALSE, TRUE),
    ('image_url', 'The URL of a small image to display on the left side of the item.', 'URL', FALSE, TRUE),
    ('color', 'The name of a color, to be displayed as a dot near the list item contents.', 'COLOR', FALSE, TRUE),
    ('active', 'Whether this item in the list is considered "active". Active items are displayed more prominently.', 'BOOLEAN', FALSE, TRUE),
    ('view_link', 'A URL to which the user should be taken when they click on the "view" icon. Does not show the icon when omitted.', 'URL', FALSE, TRUE),
    ('edit_link', 'A URL to which the user should be taken when they click on the "edit" icon. Does not show the icon when omitted.', 'URL', FALSE, TRUE),
    ('delete_link', 'A page that will be loaded when the user clicks on the delete button for this specific item. The link will be submitted as a POST request.', 'URL', FALSE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('list', 'A basic compact list', json('[{"component":"list", "compact": true, "title": "SQLPage lists are..."},{"title":"Beautiful"},{"title":"Useful"},{"title":"Versatile"}]')),
    ('list', 'An empty list with a link to add an item', json('[{"component":"list", "empty_title": "No items yet", "empty_description": "This list is empty. Click here to create a new item !", "empty_link": "documentation.sql"}]')),
    ('list', '
### A list with rich text descriptions

This example illustrates creating a nice list where each item has a title, a description, an image, and a link to another page.

> Be careful, nested links are not supported. If you use the list''s `link` property, then your markdown `description_md` should not contain any link.
', json('[{"component":"list", "wrap": true},
        {"title":"SQL Websites", "image_url": "/favicon.ico", "description_md":"Write SQL, get a website. SQLPage is a **SQL**-based **site** generator for **PostgreSQL**, **MySQL**, **SQLite** and **SQL Server**.", "link": "/"},
        {"title":"SQL Forms", "image_url": "https://upload.wikimedia.org/wikipedia/commons/b/b6/FileStack_retouched.jpg", "description_md":"Easily collect data **from users to your database** using the *form* component. Handle the data in SQL with `INSERT` or `UPDATE` queries.", "link": "?component=form"},
        {"title":"SQL Maps", "image_url": "https://upload.wikimedia.org/wikipedia/commons/1/15/Vatican_City_map_EN.png", "description_md":"Show database contents on a map using the *map* component. Works well with *PostGIS* and *SpatiaLite*.", "link": "?component=map"},
        {"title":"Advanced features", "icon": "settings", "description_md":"[Authenticate users](?component=authentication), [edit data](?component=form), [generate an API](?component=json), [maintain your database schema](/your-first-sql-website/migrations.sql), and more."}
    ]')),
    ('list', 'A beautiful list with bells and whistles.',
            json('[{"component":"list", "title":"Top SQLPage features", "compact": true },
            {"title":"Authentication", "link":"?component=authentication", "description": "Authenticate users with a login form or HTTP basic authentication", "color": "red", "icon":"lock", "active": true, "view_link": "?component=authentication#view" },
            {"title":"Editing data", "link":"?component=form", "description": "SQLPage makes it easy to UPDATE, INSERT and DELETE data in your database tables", "color": "blue", "icon":"database", "edit_link": "?component=form#edit", "delete_link": "?component=form#delete" },
            {"title":"API", "link":"?component=json", "description": "Generate a REST API from a single SQL query to connect with other applications and services", "color": "green", "icon":"plug-connected", "edit_link": "?component=json#edit", "delete_link": "?component=json#delete" }
        ]'));

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
            '{"title": "Registration form", "icon":"forms", "link": "https://github.com/sqlpage/SQLPage", "description": "Initial account data creation."},' ||
            '{"title": "Email confirmation", "icon": "mail", "link": "https://sql-page.com", "description": "Confirm your email by clicking on a link in a validation email."},' ||
            '{"title": "ID verification", "description": "Checking personal information", "icon": "user", "link": "#"},' ||
            '{"title": "Final account approval", "description": "ophir.dev", "link": "https://ophir.dev/", "icon":"eye-check", "active": true},' ||
            '{"title":"Account creation", "icon":"check"}]'));

INSERT INTO component(name, icon, description) VALUES
    ('text', 'align-left', 'A paragraph of text. The entire component will render as a single paragraph, with each item being rendered as a span of text inside it, the styling of which can be customized using parameters.');

INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'text', * FROM (VALUES
    -- top level
    ('title', 'Text header before the paragraph.', 'TEXT', TRUE, TRUE),
    ('center', 'Whether to center the title.', 'BOOLEAN', TRUE, TRUE),
    ('html', 'Raw html code to include on the page. Don''t use that if you are not sure what you are doing, it may have security implications.', 'TEXT', TRUE, TRUE),
    ('contents', 'A top-level paragraph of text to display, without any formatting, without having to make additional queries.', 'TEXT', TRUE, TRUE),
    ('contents_md', 'Rich text in the markdown format. Among others, this allows you to write bold text using `**bold**`, italics using `*italics*`, and links using `[text](https://example.com)`.', 'TEXT', TRUE, TRUE),
    ('article', 'Makes long texts more readable by increasing the line height, adding margins, using a serif font, and decorating the initial letter.', 'BOOLEAN', TRUE, TRUE),
    -- item level
    ('contents', 'A span of text to display', 'TEXT', FALSE, FALSE),
    ('contents_md', 'Rich text in the markdown format. Among others, this allows you to write bold text using `**bold**`, italics using `*italics*`, and links using `[text](https://example.com)`.', 'TEXT', FALSE, TRUE),
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
    ('text', 'Rendering rich text using markdown', json('[{"component":"text", "article": true, "contents_md":"\n'||
    '# Markdown in SQLPage\n\n' ||
    '## Simple formatting\n\n' ||
    'SQLPage supports only plain text as column values, but markdown allows easily adding **bold**, *italics*, [external links](https://github.com/sqlpage/SQLPage), [links to other pages](/index.sql) and [intra-page links](#my-paragraph). \n\n' ||
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
    '| text | A paragraph of text. | [Documentation](https://sql-page.com/documentation.sql?component=text) |\n' ||
    '| list | A list of items. | [Documentation](https://sql-page.com/documentation.sql?component=list) |\n' ||
    '| steps | A progress indicator. | [Documentation](https://sql-page.com/documentation.sql?component=steps) |\n' ||
    '| form | A series of input fields. | [Documentation](https://sql-page.com/documentation.sql?component=form) |\n\n' ||
    '## Quotes\n' ||
    '> Fantastic.\n>\n' ||
    '> — [HackerNews User](https://news.ycombinator.com/item?id=36194473#36209061) about SQLPage\n\n' ||
    '## Images\n' ||
    '![SQLPage logo](https://sql-page.com/favicon.ico)\n\n' ||
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
    ('form', 'cursor-text', '
# Building forms in SQL

The form component will display a series of input fields of various types, that can be filled in by the user.
When the user submits the form, the data is posted to an SQL file specified in the `action` property.

## Handle Data with SQL

The receiving SQL page will be able to handle the data,
and insert it into the database, use it to perform a search, format it, update existing data, etc.

A value in a field named "x" will be available as `:x` in the SQL query of the target page.

## Examples

 - [A multi-step form](https://github.com/sqlpage/SQLPage/tree/main/examples/forms-with-multiple-steps), guiding the user through a process without overwhelming them with a large form.
 - [File upload form](https://github.com/sqlpage/SQLPage/tree/main/examples/image%20gallery%20with%20user%20uploads), letting users upload images to a gallery.
 - [Rich text editor](https://github.com/sqlpage/SQLPage/tree/main/examples/rich-text-editor), letting users write text with bold, italics, links, images, etc.
 - [Master-detail form](https://github.com/sqlpage/SQLPage/tree/main/examples/master-detail-forms), to edit a list of structured items.
 - [Form with a variable number of fields](https://github.com/sqlpage/SQLPage/tree/main/examples/forms%20with%20a%20variable%20number%20of%20fields), when the fields are not known in advance.
 - [Demo of all input types](/examples/form), showing all the input types supported by SQLPage.
');
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
    ('validate_shape', 'The shape of the validation button (e.g., pill, square).', 'TEXT', TRUE, TRUE),
    ('validate_size', 'The size of the validation button (e.g., sm, lg).', 'TEXT', TRUE, TRUE),
    ('reset', 'The text to display in the button at the bottom of the form that resets the form to its original state. Omit this property not to show a reset button at all.', 'TEXT', TRUE, TRUE),
    ('id', 'A unique identifier for the form, which can then be used to validate the form from a button outside of the form.', 'TEXT', TRUE, TRUE),
    ('auto_submit', 'Automatically submit the form when the user changes any of its fields, and remove the validation button.', 'BOOLEAN', TRUE, TRUE),
    ('validate_icon', 'Name of an icon to be displayed on the left side of the submit button.', 'ICON', TRUE, TRUE),
    ('reset_icon', 'Name of an icon to be displayed on the left side of the reset button.', 'ICON', TRUE, TRUE),
    ('reset_color', 'The color of the button at the bottom of the form that resets the form to its original state. Omit this property to use the default color.', 'COLOR', TRUE, TRUE),
    ('reset_outline', 'A color to outline the reset button.', 'COLOR', TRUE, TRUE),
    ('reset_shape', 'The shape of the reset button (e.g., pill, square).', 'TEXT', TRUE, TRUE),
    ('reset_size', 'The size of the reset button (e.g., sm, lg).', 'TEXT', TRUE, TRUE),
    ('narrow', 'Whether to trim the horizontal padding between the icon and the label of the validation and reset buttons.', 'BOOLEAN', TRUE, TRUE),
    -- item level
    ('type', 'Declares input control behavior and expected format. All HTML input types are supported (text, number, date, file, checkbox, radio, hidden, ...). SQLPage adds some custom types: textarea, switch, header. text by default. See https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/input#input_types', 'TEXT', FALSE, TRUE),
    ('name', 'The name of the input field, that you can use in the target page to get the value the user entered for the field.', 'TEXT', FALSE, FALSE),
    ('label', 'A friendly name for the text field to show to the user.', 'TEXT', FALSE, TRUE),
    ('placeholder', 'A placeholder text that will be shown in the field when is is empty.', 'TEXT', FALSE, TRUE),
    ('value', 'A default value that will already be present in the field when the user loads the page.', 'TEXT', FALSE, TRUE),
    ('options', 'A json array of objects containing the label and value of initial options of a select field. Used only when type=select. JSON objects in the array can contain the properties "label", "value" and "selected".', 'JSON', FALSE, TRUE),
    ('options_source', 'Only for inputs of type `select`. URL of a SQL file that returns JSON search results for the dropdown. The SQL file receives the search text as `$search` and must return an array of objects with exactly `label` and `value`. Use `options` for options that should be available before the user searches.', 'URL', FALSE, TRUE),
    ('required', 'Set this to true to prevent the form contents from being sent if this field is left empty by the user.', 'BOOLEAN', FALSE, TRUE),
    ('min', 'The minimum value to accept for an input of type number', 'REAL', FALSE, TRUE),
    ('max', 'The maximum value to accept for an input of type number', 'REAL', FALSE, TRUE),
    ('checked', 'Used only for checkboxes and radio buttons. Indicates whether the checkbox should appear as already checked.', 'BOOLEAN', FALSE, TRUE),
    ('multiple', 'Used only for select elements. Indicates that multiple elements can be selected simultaneously. When using multiple, you should add square brackets after the variable name: ''my_variable[]'' as name', 'BOOLEAN', FALSE, TRUE),
    ('empty_option', 'Only for inputs of type `select`. Adds an empty option with the given label before the ones defined in `options`. Useful when generating other options from a database table.', 'TEXT', FALSE, TRUE),
    ('searchable', 'For select and multiple-select elements, displays them with a nice dropdown that allows searching for options.', 'BOOLEAN', FALSE, TRUE),
    ('dropdown', 'An alias for "searchable".', 'BOOLEAN', FALSE, TRUE),
    ('create_new', 'In a multiselect with a dropdown, this option allows the user to enter new values, that are not in the list of options.', 'BOOLEAN', FALSE, TRUE),
    ('step', 'The increment of values in an input of type number. Set to 1 to allow only integers.', 'REAL', FALSE, TRUE),
    ('description', 'A helper text to display near the input field.', 'TEXT', FALSE, TRUE),
    ('description_md', 'A helper text to display near the input field - formatted using markdown.', 'TEXT', FALSE, TRUE),
    ('pattern', 'A regular expression that the value must match. For instance, [0-9]{3} will only accept 3 digits.', 'TEXT', FALSE, TRUE),
    ('autofocus', 'Automatically focus the field when the page is loaded', 'BOOLEAN', FALSE, TRUE),
    ('width', 'Width of the form field, between 1 and 12.', 'INTEGER', FALSE, TRUE),
    ('autocomplete', 'Whether the browser should suggest previously entered values for this field.', 'BOOLEAN', FALSE, TRUE),
    ('minlength', 'Minimum length of text allowed in the field.', 'INTEGER', FALSE, TRUE),
    ('maxlength', 'Maximum length of text allowed in the field.', 'INTEGER', FALSE, TRUE),
    ('formaction', 'When type is "submit", this specifies the URL of the file that will handle the form submission. Useful when you need multiple submit buttons.', 'TEXT', FALSE, TRUE),
    ('formmethod', 'When type is "submit", the HTTP method to submit the form with. Takes precedence over the form''s own "method".', 'TEXT', FALSE, TRUE),
    ('formnovalidate', 'When type is "submit", skips the browser''s validation of the other fields when this button submits the form.', 'BOOLEAN', FALSE, TRUE),
    ('formtarget', 'When type is "submit", where to display the response. Takes the same values as a link target: "_blank" to open a new tab, "_self" to stay in the same one.', 'TEXT', FALSE, TRUE),
    ('accept', 'Used only for inputs of type "file". A comma-separated list of the file types the user can pick, given as extensions (".pdf,.png") or as MIME types ("image/*").', 'TEXT', FALSE, TRUE),
    ('list', 'The id of a datalist element holding the suggestions to show for this field. The datalist itself has to be rendered by the "html" component.', 'TEXT', FALSE, TRUE),
    ('class', 'A CSS class to apply to the form element.', 'TEXT', FALSE, TRUE),
    ('prefix_icon','Icon to display on the left side of the input field, on the same line.','ICON',FALSE,TRUE),
    ('prefix','Text to display on the left side of the input field, on the same line.','TEXT',FALSE,TRUE),
    ('suffix','Short text to display after th input, on the same line. Useful to add units or a currency symbol to an input.','TEXT',FALSE,TRUE),
    ('readonly','Set to true to prevent the user from modifying the value of the input field.','BOOLEAN',FALSE,TRUE),
    ('rows','Number of rows to display for a textarea. Defaults to 3.','INTEGER',FALSE,TRUE),
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
    '{"name": "Password", "type": "password", "pattern": "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$", "required": true, "description_md": "**Password Requirements:** Minimum **8 characters**, at least **one letter** & **one number**. *Tip:* Use a passphrase for better security!"},'||
    '{"label": "I accept the terms and conditions", "name": "terms", "type": "checkbox", "required": true}'||
    ']')),
    ('form','Create prepended and appended inputs to make your forms easier to use.',
    json('[{"component":"form"}, '||
    '{"name": "Your account", "prefix_icon": "mail", "prefix": "Email:", "suffix": "@mydomain.com"}, ' ||
    ']')),

    ('form','With the header type, you can group your input fields based on a theme. For example, you can categorize fields according to a person''s identity and their contact information.',
    json('[{"component":"form","title":"Information about the person"}, '||
    '{"type": "header", "label": "Identity"},' ||
    '{"name": "Name"},' ||
    '{"name": "Surname"},' ||
    '{"type": "header","label": "Contact"},' ||
    '{"name": "phone", "label": "Phone number"},' ||
    '{"name": "Email"},' ||
    ']')),

 ('form','A toggle switch in an HTML form is a user interface element that allows users to switch between two states, typically "on" and "off." It visually resembles a physical switch and is often used for settings or options that can be enabled or disabled.',
    json('[{"component":"form"},
    {"type": "switch", "label": "Dark theme", "name": "dark", "description": "Enable dark theme"},
    {"type": "switch", "label": "A required toggle switch", "name": "my_checkbox", "required": true,"checked": true},
    {"type": "switch", "label": "A disabled toggle switch", "name": "my_field", "disabled": true}
    ]')),

    ('form', 'This example illustrates the use of the `select` type.
In this select input, the various options are hardcoded, but they could also be loaded from a database table,
[using a function to convert the rows into a json array](/blog.sql?post=JSON%20in%20SQL%3A%20A%20Comprehensive%20Guide) like 
 - `json_group_array()` in SQLite,
 - `json_agg()` in Postgres,
 - `JSON_ARRAYAGG()` in MySQL, or
 - `FOR JSON PATH` in Microsoft SQL Server.


In SQLite, the query would look like
```sql
SELECT 
    ''select'' as type,
    ''Select a fruit...'' as empty_option,
    json_group_array(json_object(
        ''label'', name,
        ''value'', id
    )) as options
FROM fruits
```
', json('[{"component":"form", "action":"examples/show_variables.sql"},
    {"name": "Fruit", "type": "select",
        "empty_option": "Select a fruit...",
        "options":
            "[{\"label\": \"Orange\", \"value\": 0}, {\"label\": \"Apple\", \"value\": 1}, {\"label\": \"Banana\", \"value\": 3}]"}
    ]')),
    ('form', '### Multi-select
You can authorize the user to select multiple options by setting the `multiple` property to `true`.
This creates a more compact (but arguably less user-friendly) alternative to a series of checkboxes.
In this case, you should add square brackets to the name of the field (e.g. `''my_field[]'' as name`).
The target page will then receive the value as a JSON array of strings, which you can iterate over using 
 - the `json_each` function [in SQLite](https://www.sqlite.org/json1.html) and [Postgres](https://www.postgresql.org/docs/9.3/functions-json.html),
 - the [`OPENJSON`](https://learn.microsoft.com/fr-fr/sql/t-sql/functions/openjson-transact-sql?view=sql-server-ver16) function in Microsoft SQL Server.
 - in MySQL, json manipulation is less straightforward: see [the SQLPage MySQL json example](https://github.com/sqlpage/SQLPage/tree/main/examples/mysql%20json%20handling)

[More information on how to handle JSON in SQL](/blog.sql?post=JSON%20in%20SQL%3A%20A%20Comprehensive%20Guide).

The target page could then look like this:

```sql
insert into best_fruits(id) -- INSERT INTO ... SELECT ... runs the SELECT query and inserts the results into the table
select CAST(value AS integer) as id -- all values are transmitted by the browser as strings
from json_each($my_field); -- in SQLite, json_each returns a table with a "value" column for each element in the JSON array
```

### Example multiselect generated from a database table

If you have a table of all possible options (`my_options(id int, label text)`),
and want to generate a multi-select field from it, you have two options:
- if the number of options is not too large, you can use the `options` parameter to return them all as a JSON array in the SQL query
- if the number of options is large (e.g. more than 1000), you can use `options_source` to load options dynamically from a different SQL query as the user types

#### Embedding all options in the SQL query

Let''s say you have a table that contains the selected options per user (`my_user_options(user_id int, option_id int)`).
You can use a query like this to generate the multi-select field:

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

This will generate a json array of objects, each containing the label, value and selected status of each option.

#### Loading options dynamically from a different SQL query with `options_source`

If the `my_options` table has a large number of rows, you can use the `options_source` parameter to load options dynamically from a different SQL query as the user types.

We''ll write a second SQL file, `options_source.sql`, that will receive the user''s search string as a parameter named `$search`,
 and return a json array of objects, each containing the label and value of each option.

When both `options` and `options_source` are set, the local `options` are loaded first. Search results from `options_source` are loaded into the same option list; a result with the same `value` updates the existing option. This is useful to set a default preselected value with `options_source`.

`options_source` may already contain query parameters. SQLPage preserves them and adds or replaces the `search` parameter when loading options.

##### `options_source.sql`

```sql
select ''json'' as component;

select id as value, label as label
from my_options
where label like $search || ''%'';
```

##### `form`

', json('[{"component":"form", "action":"examples/show_variables.sql", "reset": "Reset"}, 
    {"name": "component", "type": "select",
    "value": "form",
    "options": [{"label": "Form", "value": "form"}],
    "options_source": "examples/from_component_options_source.sql?category=component",
    "description": "Start typing the name of a component like ''map'' or ''form''..."
    }]')),
    ('form', 'This example illustrates the use of the `radio` type.
The `name` parameter is used to group the radio buttons together.
The `value` parameter is used to set the value that will be submitted when the user selects the radio button.
The `label` parameter is used to display a friendly name for the radio button.
The `description` parameter is used to display a helper text near the radio button.

We could also save all the options in a database table, and then run a simple query like

```sql
SELECT ''form'' AS component;
SELECT 
    ''radio'' as type,
    ''db'' as name,
    option_name as label,
    option_id as value
FROM my_options;
```

In this example, depending on what the user clicks, the page will be reloaded with a the variable `$component` set to the string "form", "map", or "chart".

    ', json('[{"component":"form", "method": "GET"},
    {"name": "component", "type": "radio", "value": "form", "description": "Read user input in SQL", "label": "Form"},
    {"name": "component", "type": "radio", "value": "map", "checked": true, "description": "Display a map based on database data", "label": "Map"},
    {"name": "component", "type": "radio", "value": "chart", "description": "Interactive plots of SQL query results", "label": "Chart"}
    ]')),
    ('form', '
### Dynamically refresh the page when the user changes the form

The form will be automatically submitted when the user changes any of its fields, and the page will be reloaded with the new value.
The validation button is removed.
', json('[{"component":"form", "auto_submit": true},
    {"name": "component", "type": "select", "autocomplete": false, "options": [
        {"label": "Form", "value": "form", "selected": true},
        {"label": "Map", "value": "map"},
        {"label": "Chart", "value": "chart"}
    ], "description": "Choose a component to view its documentation. No need to click a button, the page will be reloaded automatically.", "label": "Component"}
    ]')),
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
INSERT INTO uploaded_file(name, data)
VALUES (
    :filename,
    sqlpage.read_file_as_data_url(sqlpage.uploaded_file_path(''my_file''))
)
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
    ('type', 'The type of chart. One of: "line", "area", "bar", "column", "pie", "scatter", "bubble", "heatmap", "rangeBar". "column" is a synonym of "bar".', 'TEXT', TRUE, FALSE),
    ('time', 'Whether the x-axis represents time. If set to true, the x values will be parsed and formatted as dates for the user.', 'BOOLEAN', TRUE, TRUE),
    ('xmin', 'The minimal value for the x-axis. When time is true, this can be a date or timestamp.', 'TEXT', TRUE, TRUE),
    ('xmax', 'The maximum value for the x-axis. When time is true, this can be a date or timestamp.', 'TEXT', TRUE, TRUE),
    ('ymin', 'The minimal value for the y-axis.', 'REAL', TRUE, TRUE),
    ('ymax', 'The maximum value for the y-axis.', 'REAL', TRUE, TRUE),
    ('xtitle', 'Title of the x axis, displayed below it.', 'TEXT', TRUE, TRUE),
    ('ytitle', 'Title of the y axis, displayed to its left.', 'TEXT', TRUE, TRUE),
    ('ztitle', 'Title of the z axis, displayed in tooltips.', 'TEXT', TRUE, TRUE),
    ('xticks', 'Number of intervals used to generate a numeric x-axis, normally producing one more tick position. On category and time axes, this is a target for label density, so the visible label count may differ.', 'INTEGER', TRUE, TRUE),
    ('yticks', 'Number of ticks on the y axis.', 'INTEGER', TRUE, TRUE),
    ('ystep', 'Step between ticks on the y axis.', 'REAL', TRUE, TRUE),
    ('marker', 'Marker size', 'REAL', TRUE, TRUE),
    ('labels', 'Whether to show the data labels on the chart or not.', 'BOOLEAN', TRUE, TRUE),
    ('color', 'The name of a color in which to display the chart. If there are multiple series in the chart, this parameter can be repeated multiple times.', 'COLOR', TRUE, TRUE),
    ('stacked', 'Whether to cumulate values from different series. Supported by the "line", "area" and "bar" chart types, and ignored by the others. Series are aligned on their x values, and a series that has no value for a given x counts as zero there.', 'BOOLEAN', TRUE, TRUE),
    ('toolbar', 'Whether to display a toolbar at the top right of the chart, that offers downloading the data as CSV.', 'BOOLEAN', TRUE, TRUE),
    ('show_legend', 'Whether to display the legend listing all chart series. Defaults to true.', 'BOOLEAN', TRUE, TRUE),
    ('logarithmic', 'Display the y-axis in logarithmic scale.', 'BOOLEAN', TRUE, TRUE),
    ('horizontal', 'Displays a bar chart with horizontal bars instead of vertical ones.', 'BOOLEAN', TRUE, TRUE),
    ('height', 'Height of the chart, in pixels. By default: 250', 'INTEGER', TRUE, TRUE),
    -- item level
    ('x', 'The value of the point on the horizontal axis. Numeric values use continuous, proportionate positioning; text values are evenly spaced categories. Set the top-level time property for dates and timestamps.', 'REAL', FALSE, FALSE),
    ('y', 'The value of the point on the vertical axis', 'REAL', FALSE, FALSE),
    ('z', 'A third value carried by the point. Used as the bubble radius in a bubble chart, and shown in the tooltip under the name given by the top-level "ztitle".', 'REAL', FALSE, TRUE),
    ('label', 'An alias for parameter "x". On a row that draws a reference line, the text to display next to the line.', 'TEXT', FALSE, TRUE),
    ('value', 'An alias for parameter "y"', 'REAL', FALSE, TRUE),
    ('series', 'If multiple series are represented and share the same y-axis, this parameter can be used to distinguish between them.', 'TEXT', FALSE, TRUE),
    ('yline', 'Draws a reference line across the chart at this value of the y axis instead of plotting a point, to show a limit such as a quota or an alarm threshold. Not drawn if it falls outside of the axis, so set ymax when the limit is above the data.', 'REAL', FALSE, TRUE),
    ('yline_end', 'Makes the yline a band instead of a line, reaching to this value.', 'REAL', FALSE, TRUE),
    ('xline', 'Draws a reference line across the chart at this position of the x axis instead of plotting a point, to mark an event such as a deployment. A date or a timestamp when time is set, otherwise one of the x values.', 'TEXT', FALSE, TRUE),
    ('xline_end', 'Makes the xline a band instead of a line, reaching to this value.', 'TEXT', FALSE, TRUE),
    ('color', 'The name of a color for what this row draws: the bar, slice or point it plots, or the reference line it draws. Defaults to the color of the series for a data point, and to grey for a reference line.', 'COLOR', FALSE, TRUE)
) x;
INSERT INTO example(component, description, properties) VALUES
    ('chart', 'An area chart representing a time series, using the top-level property `time`.
    Ticks on the x axis are adjusted automatically, and ISO datetimes are parsed and displayed in a readable format.', json('[
    {
        "component": "chart",
        "title": "Quarterly Revenue",
        "type": "area",
        "color": "blue-lt",
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
    ('chart', 'A pie chart.', json('[{"component":"chart", "title": "Answers", "type": "pie", "labels": true},
    {"label": "Yes", "value": 65},
    {"label": "No", "value": 35}]')),
    ('chart', 'A basic bar chart', json('[
        {"component":"chart", "type": "bar", "title": "Quarterly Results", "horizontal": true, "labels": true},
        {"label": "Tom", "value": 35}, {"label": "Olive", "value": 15}]')),
    ('chart', 'A TreeMap Chart allows you to display hierarchical data in a nested layout. This is useful for  visualizing the proportion of each part to the whole.',
        json('[
        {"component":"chart", "type": "treemap", "title": "Quarterly Results By Region (in k$)", "labels": true },
        {"series": "North America", "label": "United States", "value": 35},
        {"series": "North America", "label": "Canada", "value": 15},
        {"series": "Europe", "label": "France", "value": 30},
        {"series": "Europe", "label": "Germany", "value": 55},
        {"series": "Asia", "label": "China", "value": 20},
        {"series": "Asia", "label": "Japan", "value": 10}
    ]')),
    ('chart', 'A bar chart with multiple series.', json('[{"component":"chart", "title": "Expenses", "type": "bar", "stacked": true, "toolbar": true, "show_legend": false, "ystep": 10}, '||
    '{"series": "Marketing", "x": 2021, "value": 35}, '||
    '{"series": "Marketing", "x": 2022, "value": 15}, '||
    '{"series": "Human resources", "x": 2021, "value": 30}, '||
    '{"series": "Human resources", "x": 2022, "value": 55}]')),
    ('chart', 'A stacked area chart, showing how each series contributes to a total.
The `stacked` property also works with the `line` and `bar` chart types.

Series are aligned on their `x` values, and a series that has no value for a given `x` counts as zero there:
below, the graphics card draws no power outside of the render.
If a missing value does not mean zero in your data, make all the series share the same `x` values,
for instance by rounding timestamps to a common interval.',
    json('[{"component":"chart", "title": "Power draw", "type": "area", "stacked": true, "time": true, "ytitle": "watts", "color": ["blue", "teal"], "marker": 4}, '||
    '{"series": "CPU", "x": "2024-03-01T10:00:00Z", "value": 45}, '||
    '{"series": "CPU", "x": "2024-03-01T10:15:00Z", "value": 52}, '||
    '{"series": "CPU", "x": "2024-03-01T10:30:00Z", "value": 48}, '||
    '{"series": "CPU", "x": "2024-03-01T10:45:00Z", "value": 44}, '||
    '{"series": "GPU", "x": "2024-03-01T10:15:00Z", "value": 120}, '||
    '{"series": "GPU", "x": "2024-03-01T10:30:00Z", "value": 140}]')),
    ('chart', 'A line chart with multiple series. One of the most common types of charts, often used to show trends over time.
Also demonstrates the use of the `toolbar` attribute to allow the user to download the graph as an image or the data as a CSV file.', 
    json('[{"component":"chart", "title": "Revenue", "ymin": 0, "toolbar": true},
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
        "ytitle": "Database managemet system", "xtitle": "Year", "color": ["purple","purple","purple"]},
        { "series": "PostgreSQL", "x": "2000", "y": 48},{ "series": "SQLite", "x": "2000", "y": 44},{ "series": "MySQL", "x": "2000", "y": 78},
        { "series": "PostgreSQL", "x": "2010", "y": 65},{ "series": "SQLite", "x": "2010", "y": 62},{ "series": "MySQL", "x": "2010", "y": 83},
        { "series": "PostgreSQL", "x": "2020", "y": 73},{ "series": "SQLite", "x": "2020", "y": 38},{ "series": "MySQL", "x": "2020", "y": 87}
      ]')),
    ('chart', 'A timeline displaying events with a start and an end date',
    json('[
        {"component":"chart", "title": "Project Timeline", "type": "rangeBar", "time": true, "color": ["teal", "cyan"], "labels": true, "xmin": "2021-12-28", "xmax": "2022-01-04" },
        {"series": "Phase 1", "label": "Operations", "value": ["2021-12-29", "2022-01-02"]},
        {"series": "Phase 2", "label": "Operations", "value": ["2022-01-03", "2022-01-04"]},
        {"series": "Yearly maintenance", "label": "Maintenance", "value": ["2022-01-01", "2022-01-03"]}
    ]')),
    ('chart', '
## Coloring a single value

A data row can carry its own `color`, to paint the one bar, slice or point it
plots. Use it when the color says something the axes do not: a threshold
crossed, a status, the one category the reader should look at first.

```sql
select ''chart'' as component, ''bar'' as type, true as horizontal,
    true as labels, false as show_legend;
select
    window_label as label,
    accounts as value,
    case when days <= 30 then ''red'' when days <= 60 then ''orange'' else ''green'' end as color
from expiring_accounts order by days;
```

A row color takes precedence over the color of its series. On a `line` or an
`area` chart it paints the marker of the point, so set `marker` for it to show.
A `heatmap` shades its cells from their own value and ignores it.
', json('[
        {"component":"chart", "title": "Accounts expiring soon", "type": "bar",
         "horizontal": true, "labels": true, "show_legend": false},
        {"label": "30 days", "value": 100, "color": "red"},
        {"label": "60 days", "value": 200, "color": "orange"},
        {"label": "90 days", "value": 300, "color": "green"}
    ]')),
    ('chart', 'A pie chart whose rows choose their own slice colors.', json('[
        {"component":"chart", "title": "Support tickets", "type": "pie", "labels": true},
        {"label": "Resolved", "value": 72, "color": "green"},
        {"label": "In progress", "value": 21, "color": "yellow"},
        {"label": "Overdue", "value": 7, "color": "red"}
    ]')),
    ('chart', '
## Reference lines

A row with a `yline` is not plotted as a data point, but drawn as a line across
the whole chart, at that value of the y axis. Use it for the limit that the data
should be read against: a disk quota, an alarm threshold, a service level
objective. Add `yline_end` to make it a band instead of a line.

Reference lines are rows, so they come from a query like everything else,
and a chart can have as many of them as the query returns:

```sql
select ''chart'' as component, ''CPU temperature'' as title, true as time, 100 as ymax;
select celsius as yline, name as label, color as color from thresholds;
select measured_at as x, celsius as y from readings order by measured_at;
```

They are drawn as annotations rather than as an extra series, so they are not
added to the total of a `stacked` chart, and are not filled in an `area` chart.

A line outside of the y axis is not drawn, and does not stretch the axis to fit,
so set `ymax` when the limit is above the data.
', json('[
        {"component":"chart", "title": "CPU temperature", "type": "line", "time": true,
         "ytitle": "°C", "ymax": 100, "color": "azure", "marker": 4},
        {"yline": 70, "label": "target", "color": "green"},
        {"yline": 90, "yline_end": 100, "label": "throttling", "color": "red"},
        {"x": "2024-05-01T08:00:00Z", "y": 52},
        {"x": "2024-05-01T09:00:00Z", "y": 58},
        {"x": "2024-05-01T10:00:00Z", "y": 71},
        {"x": "2024-05-01T11:00:00Z", "y": 83},
        {"x": "2024-05-01T12:00:00Z", "y": 94},
        {"x": "2024-05-01T13:00:00Z", "y": 76},
        {"x": "2024-05-01T14:00:00Z", "y": 63}
    ]')),
    ('chart', '
## Marking events

`xline` is the counterpart of `yline`: it marks a position on the x axis instead
of a value on the y axis. On its own it marks a moment, like a deployment.
With `xline_end`, it covers everything in between, like an incident or a
maintenance window. A single query can draw a whole log of them:

```sql
select started_at as xline, ended_at as xline_end, summary as label,
    case severity when ''outage'' then ''red'' else ''orange'' end as color
from incidents where started_at > $since;
```

When `time` is set, an `xline` is a date or a timestamp, written like the `x` of
a data point. On a chart with text labels on the x axis, it is one of those labels.
', json('[
        {"component":"chart", "title": "Request latency", "type": "area", "time": true,
         "ytitle": "ms", "color": "blue-lt", "marker": 3},
        {"xline": "2024-05-01T10:00:00Z", "label": "deploy", "color": "green"},
        {"xline": "2024-05-01T11:30:00Z", "xline_end": "2024-05-01T13:00:00Z",
         "label": "incident", "color": "red"},
        {"x": "2024-05-01T08:00:00Z", "y": 120},
        {"x": "2024-05-01T09:00:00Z", "y": 134},
        {"x": "2024-05-01T10:00:00Z", "y": 128},
        {"x": "2024-05-01T11:00:00Z", "y": 141},
        {"x": "2024-05-01T12:00:00Z", "y": 512},
        {"x": "2024-05-01T13:00:00Z", "y": 470},
        {"x": "2024-05-01T14:00:00Z", "y": 156},
        {"x": "2024-05-01T15:00:00Z", "y": 133}
    ]')),
    ('chart', '
## Reference lines follow their axis

A reference belongs to the column it is written in, not to a direction on the
screen. `yline` always marks a value of `y`, and `xline` a position on `x`,
whichever way round the chart is drawn. A `horizontal` bar chart runs its y axis
from left to right, so a `yline` is drawn down the chart and an `xline` picks out
one of the bars.

```sql
select ''chart'' as component, ''bar'' as type, true as horizontal, 100 as ymax;
select 90 as yline, ''full'' as label, ''red'' as color;
select ''db-1'' as xline, ''watched'' as label, ''purple'' as color;
select host as x, percent_used as y from disks order by percent_used;
```

A `pie` has no axes and ignores reference lines, and on a `heatmap`, whose y axis
holds the names of the series, only `xline` has a meaning.
', json('[
        {"component":"chart", "title": "Disk usage", "type": "bar", "horizontal": true,
         "ymax": 100, "color": "azure", "labels": true},
        {"yline": 90, "label": "full", "color": "red"},
        {"xline": "db-1", "label": "watched", "color": "purple"},
        {"x": "backup-1", "y": 41},
        {"x": "web-2", "y": 63},
        {"x": "db-1", "y": 88},
        {"x": "web-1", "y": 96}
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
            {"embed": "/examples/chart.sql?color=green&n=42&_sqlpage_embed"},
            {"embed": "/examples/chart.sql?_sqlpage_embed" }
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
    ('initial_search_value', 'Pre-fills the search bar used to filter the table. The user will still be able to edit the value to display table rows that will initially be filtered out.', 'TEXT', TRUE, TRUE),
    ('search_placeholder', 'Customizes the placeholder text shown in the search input field. Replaces the default "Search..." with text that better describes what users should search for.', 'TEXT', TRUE, TRUE),
    ('markdown', 'Set this to the name of a column whose content should be interpreted as markdown. Used to display rich text with links in the table. This argument can be repeated multiple times to intepret multiple columns as markdown.', 'TEXT', TRUE, TRUE),
    ('icon', 'Set this to the name of a column whose content should be interpreted as a tabler icon name. Used to display icons in the table. This argument can be repeated multiple times to intepret multiple columns as icons. Introduced in v0.8.0.', 'TEXT', TRUE, TRUE),
    ('align_right', 'Name of a column the contents of which should be right-aligned. This argument can be repeated multiple times to align multiple columns to the right. Introduced in v0.15.0.', 'TEXT', TRUE, TRUE),
    ('align_center', 'Name of a column the contents of which should be center-aligned. This argument can be repeated multiple times to align multiple columns to the center.', 'TEXT', TRUE, TRUE),
    ('monospace', 'Name of a column the contents of which should be displayed in monospace. This argument can be repeated multiple times to display multiple columns in monospace. Introduced in v0.32.1.', 'TEXT', TRUE, TRUE),
    ('striped_rows', 'Whether to add zebra-striping to any table row.', 'BOOLEAN', TRUE, TRUE),
    ('striped_columns', 'Whether to add zebra-striping to any table column.', 'BOOLEAN', TRUE, TRUE),
    ('hover', 'Whether to enable a hover state on table rows.', 'BOOLEAN', TRUE, TRUE),
    ('border', 'Whether to draw borders on all sides of the table and cells.', 'BOOLEAN', TRUE, TRUE),
    ('overflow', 'Whether to to let "wide" tables overflow across the right border and enable browser-based horizontal scrolling.', 'BOOLEAN', TRUE, TRUE),
    ('small', 'Whether to use compact table.', 'BOOLEAN', TRUE, TRUE),
    ('description','Description of the table contents. Helps users with screen readers to find a table and understand what it’s about.','TEXT',TRUE,TRUE),
    ('empty_description', 'Text to display if the table does not contain any row. Defaults to "no data".', 'TEXT', TRUE, TRUE),
    ('freeze_columns', 'Whether to freeze the leftmost column of the table.', 'BOOLEAN', TRUE, TRUE),
    ('freeze_headers', 'Whether to freeze the top row of the table.', 'BOOLEAN', TRUE, TRUE),
    ('freeze_footers', 'Whether to freeze the footer (bottom row) of the table, only works if that row has the `_sqlpage_footer` property applied to it.', 'BOOLEAN', TRUE, TRUE),
    ('raw_numbers', 'Name of a column whose values are numeric, but should be displayed as raw numbers without any formatting (no thousands separators, decimal separator is always a dot). This argument can be repeated multiple times.', 'TEXT', TRUE, TRUE),
    ('money', 'Name of a numeric column whose values should be displayed as currency amounts, in the currency defined by the `currency` property. This argument can be repeated multiple times.', 'TEXT', TRUE, TRUE),
    ('currency', 'The ISO 4217 currency code (e.g., USD, EUR, GBP, etc.) to use when formatting monetary values.', 'TEXT', TRUE, TRUE),
    ('number_format_digits', 'Maximum number of decimal digits to display for numeric values.', 'INTEGER', TRUE, TRUE),
    ('number_format_locale', 'A BCP 47 language tag (e.g. "de-DE", "en-IN") deciding how numbers and monetary values are formatted. Defaults to the locale of the visitor''s browser.', 'TEXT', TRUE, TRUE),
    ('edit_url', 'If set, an edit button will be added to each row. The value of this property should be a URL, possibly containing the `{id}` placeholder that will be replaced by the value of the `_sqlpage_id` property for that row. Clicking the edit button will take the user to that URL. Added in v0.39.0', 'TEXT', TRUE, TRUE),
    ('delete_url', 'If set, a delete button will be added to each row. The value of this property should be a URL, possibly containing the `{id}` placeholder that will be replaced by the value of the `_sqlpage_id` property for that row. Clicking the delete button will take the user to that URL. Added in v0.39.0', 'TEXT', TRUE, TRUE),
    ('custom_actions', 'If set, a column of custom action buttons will be added to each row. The value of this property should be a JSON array of objects, each object defining a button with the following properties: `name` (the text to display on the button), `icon` (the tabler icon name or image link to display on the button), `link` (the URL to navigate to when the button is clicked, possibly containing the `{id}` placeholder that will be replaced by the value of the `_sqlpage_id` property for that row), and `tooltip` (optional text to display when hovering over the button). Added in v0.39.0', 'JSON', TRUE, TRUE),
    ('column_visibility','Specify the minimum screen resolution at which the columns should be displayed for `phone`, `tablet`, `desktop`, and `large_desktop`. Defaults to `phone`. Introduced in v0.47.0.', 'JSON', TRUE, TRUE),
    ('badges','Set this to the name of a column whose content should be interpreted as badges. This argument can be repeated multiple times to intepret multiple columns as badges. Introduced in v0.47.0.','TEXT',TRUE,TRUE),
    -- row level
    ('_sqlpage_css_class', 'For advanced users. Sets a css class on the table row. Added in v0.8.0.', 'TEXT', FALSE, TRUE),
    ('_sqlpage_color', 'Sets the background color of the row. Added in v0.8.0.', 'COLOR', FALSE, TRUE),
    ('_sqlpage_footer', 'Sets this row as the table footer. It is recommended that this parameter is applied to the last row. Added in v0.34.0.', 'BOOLEAN', FALSE, TRUE),
    ('_sqlpage_id', 'Sets the id of the html tabler row element. Allows you to make links targeting a specific row in a table.', 'TEXT', FALSE, TRUE),
    ('_sqlpage_actions', 'Sets custom action buttons for this specific row in addition to any defined at the table level, The value of this property should be a JSON array of objects, each object defining a button with the following properties: `name` (the text to display on the button), `icon` (the tabler icon name or image link to display on the button), `link` (the URL to navigate to when the button is clicked, possibly containing the `{id}` placeholder that will be replaced by the value of the `_sqlpage_id` property for that row), and `tooltip` (optional text to display when hovering over the button). Added in v0.39.0', 'JSON', FALSE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('table', 'The most basic table.',
        json('[{"component":"table"}, {"a": 1, "b": 2}, {"a": 3, "b": 4}]')),
    ('table', 'A table of users with filtering and sorting.',
        json('[
        {"component":"table", "sort":true, "search":true, "search_placeholder": "Filter by name"},
        {"First Name": "Ophir", "Last Name": "Lojkine", "Pseudonym": "lovasoa"},
        {"First Name": "Linus", "Last Name": "Torvalds", "Pseudonym": "torvalds"}
    ]')),
    ('table', 'A table that uses markdown to display links',
        json('[{"component":"table", "markdown": "Name", "icon": "icon", "search": true}, '||
        '{"icon": "table", "name": "[Table](?component=table)", "description": "Displays SQL results as a searchable table.", "_sqlpage_color": "red"},
        {"icon": "timeline", "name": "[Chart](?component=chart)", "description": "Show graphs based on numeric data."}
        ]')),
    (
        'table', 'A table that uses badges to display user permissions.
        
To describe the badges contained in a column, you need to create a JSON array. Each object represents a badge defined 
using the following properties:

- `title`: the text displayed on the badge.
- `size`: the size of the badge (e.g., sm, lg).
- `color`: the color of the badge (e.g., red, green, blue, but also primary, warning, danger, etc.). Only base color names are supported.
- `light`: create a light version of the badge (boolean).
- `pill`: badge with rounded corners (boolean).
- `link`: add a link to the badge and make it clickable.                                 

        ',
        json(
        '[{"component":"table", "badges": "Permissions"},
         {"Username": "john.doe", "Permissions": [{"title":"read","color":"green"}]},
         {"Username": "mary.johnson", "Permissions": [{"title":"admin","color":"blue"},{"title":"read","color":"green"},{"title":"write","color":"blue"}]},
         {"Username": "robert.brown", "Permissions": [{"title":"read","color":"green"},{"title":"write","color":"blue"}]},
         {"Username": "emily.davis", "Permissions": [{"title":"read","color":"blue"}]},
         {"Username": "michael.wilson", "Permissions": [{"title":"read","color":"green"},{"title":"write","color":"blue"}]},
        ]'
    )),
    ('table', 'A sortable table with a colored footer showing the average value of its entries.',
        json('[{"component":"table", "sort":true}, '||
        '{"Person": "Rudolph Lingens", "Height": 190},' ||
        '{"Person": "Jane Doe", "Height": 150},' ||
        '{"Person": "John Doe", "Height": 200},' ||
        '{"_sqlpage_footer":true, "_sqlpage_color": "green", "Person": "Average", "Height": 180}]')),
    (
    'table',
    'A table with column sorting. Sorting sorts numbers in numeric order, and strings in alphabetical order.

Numbers can be displayed 
 - as raw digits without formatting using the `raw_numbers` property,
 - as currency using the `money` property to define columns that contain monetary values and `currency` to define the currency,
 - as numbers with a fixed maximum number of decimal digits using the `number_format_digits` property.
',
    json(
        '[{"component":"table", "sort": true, "align_right": ["Price", "Amount in stock"], "align_center": ["part_no"], "raw_numbers": ["id"], "currency": "USD", "money": ["Price"] },
         {"id": 31456, "part_no": "SQL-TABLE-856-G", "Price": 12, "Amount in stock": 5},
          {"id": 996, "part_no": "SQL-FORMS-86-M", "Price": 1, "Amount in stock": 1234},
          {"id": 131456, "part_no": "SQL-CARDS-56-K", "Price": 127, "Amount in stock": 98}
        ]'
    )),
    (
    'table',
    'A table with some presentation options',
    json(
        '[{"component":"table",
                "hover": true, "striped_rows": true,
                "description": "Some Star Trek Starfleet starships",
                "small": true, "initial_search_value": "NCC-"
        },
         {"name": "USS Enterprise", "registry": "NCC-1701-C", "class":"Ambassador"},
         {"name": "USS Archer", "registry": "NCC-44278", "class":"Archer"},
         {"name": "USS Endeavour", "registry": "NCC-06", "class":"Columbia"},
         {"name": "USS Constellation", "registry": "NCC-1974", "class":"Constellation"},
         {"name": "USS Dakota", "registry": "NCC-63892", "class":"Akira"},
         {"name": "USS Defiant", "registry": "IX-74205", "class":"Defiant"}
        ]'
    )),
    (
    'table',
    'An empty table with a friendly message',
    json('[{"component":"table", "empty_description": "Nothing to see here at the moment."}]')
    ),
    (
    'table',
    'A large table with many rows and columns, with frozen columns on the left and headers on top. This allows users to browse large datasets without loosing track of their position.',
    json('[
    {"component": "table", "freeze_columns": true, "freeze_headers": true},
    {
        "feature": "SQL Execution",
        "description": "Fully compatible with existing databases SQL dialects, executes any SQL query.",
        "benefits": "Short learning curve, easy to use, interoperable with existing tools."
    },
    {
        "feature": "Data Visualization",
        "description": "Automatic visualizations of query results: graphs, plots, pie charts, heatmaps, etc.",
        "benefits": "Quickly analyze data trends, attractive and easy to understand, no external visualization tools or languages to learn."
    },
    {
        "feature": "User Authentication",
        "description": "Supports user sessions, from basic auth to single sign-on.",
        "benefits": "Secure, enforces access control policies, and provides a customizable security layer."
    },
    {
        "feature": "APIs",
        "description": "Allows building JSON REST APIs and integrating with external APIs.",
        "benefits": "Enables automation and integration with other platforms, facilitates data exchange."
    },
    {
        "feature": "Files",
        "description": "File uploads, downloads and processing. Supports local filesystem and database storage.",
        "benefits": "Convenient file management, secure data handling, flexible storage options, integrates with existing systems."
    },
    {
        "feature": "Maps",
        "description": "Supports GeoJSON and is compatible with GIS data for map visualization.",
        "benefits": "Geospatial data representation, integrates with geographic information systems."
    },
    {
        "feature": "Custom Components",
        "description": "Build advanced features using HTML, JavaScript, and CSS.",
        "benefits": "Tailor-made user experiences, easy to implement custom UI requirements."
    },
    {
        "feature": "Forms",
        "description": "Insert and update data in databases based on user input.",
        "benefits": "Simplified data input and management, efficient user interactions with databases."
    },
    {
        "feature": "DB Compatibility",
        "description": "Works with MySQL, PostgreSQL, SQLite, Microsoft SQL Server and compatible databases.",
        "benefits": "Broad compatibility with popular database systems, ensures seamless integration."
    },
    {
        "feature": "Security",
        "description": "Built-in protection against common web vulnerabilities: no SQL injection, no XSS.",
        "benefits": "Passes audits and security reviews, reduces the risk of data breaches."
    },
    {
        "feature": "Performance",
        "description": "Designed for performance, with a focus on efficient data processing and minimal overhead.",
        "benefits": "Quickly processes large datasets, handles high volumes of requests, and minimizes server load."
    },
    {
        "_sqlpage_footer": true,
        "feature": "Summary",
        "description": "Summarizes the features of the product.",
        "benefits": "Provides a quick overview of the product''s features and benefits."
    }
]')
    ),
    (
    'table',
    'A table that adapts its layout to the resolution of the device being used.

If your table contains many columns, it won’t be comfortable to read on a mobile device such as a phone or tablet. 
To solve this problem, the `column_visibility` setting allows you to specify the minimum resolution at which 
a column should be displayed.

- `phone`: The column is displayed on all devices.
- `tablet`: The column is displayed on all devices with width greater than 768px.
- `desktop`: The column is displayed on all devices with width greater than 992px.
- `large_desktop`: The column is displayed only on devices with width greater than 1200px.

To specify column visibility, simply provide a JSON object in which the column name is the key and the selected resolution 
is the value. By default, a column is visible starting at the `phone` resolution.

To try the example below, feel free to resize your browser window.
    ',
    json(
        '[{"component":"table",
                "hover": true, "striped_rows": true,
                "description": "Some Star Trek Starfleet starships",
                "small": true,
                "column_visibility": {"registry":"tablet","class":"desktop","commander":"large_desktop"}
        },
         {"name": "USS Enterprise", "registry": "NCC-1701", "class":"Constitution", "commander": "James T. Kirk"},
         {"name": "USS Voyager", "registry": "NCC-74656", "class":"Intrepid", "commander": "Kathryn Janeway"},
         {"name": "USS Constellation", "registry": "NCC-1974", "class":"Constellation","commander": "Matt Decker"},
         {"name": "USS Enterprise", "registry": "NX-01", "class":"Ambassador", "commander": "Jonathan Archer"},
         {"name": "USS Defiant", "registry": "IX-74205", "class":"Defiant", "commander": "Benjamin Sisko"}
        ]'
    )),
    (
    'table',
    '# Dynamic column names in a table

In all the previous examples, the column names were hardcoded in the SQL query.
This makes it very easy to quickly visualize the results of a query as a table,
but it can be limiting if you want to include columns that are not known in advance.
In situations when the number and names of the columns depend on the data, or on variables,
you can use the `dynamic` component to generate the table columns dynamically.

For that, you will need to return JSON objects from your SQL query, where the keys are the column names,
and the values are the cell contents.

Databases [offer utilities to generate JSON objects from query results](/blog.sql?post=JSON%20in%20SQL%3A%20A%20Comprehensive%20Guide)
 - In PostgreSQL, you can use the [`json_build_object`](https://www.postgresql.org/docs/current/functions-json.html#FUNCTIONS-JSON-PROCESSING)
function for a fixed number of columns, or [`json_object_agg`](https://www.postgresql.org/docs/current/functions-aggregate.html#FUNCTIONS-AGGREGATE) for a dynamic number of columns.
 - In SQLite, you can use the [`json_object`](https://www.sqlite.org/json1.html) function for a fixed number of columns,
or the `json_group_object` function for a dynamic number of columns.
 - In MySQL, you can use the [`JSON_OBJECT`](https://dev.mysql.com/doc/refman/8.0/en/json-creation-functions.html#function_json-object) function for a fixed number of columns,
or the [`JSON_OBJECTAGG`](https://dev.mysql.com/doc/refman/8.4/en/aggregate-functions.html#function_json-objectagg) function for a dynamic number of columns.
 - In Microsoft SQL Server, you can use the [`FOR JSON PATH`](https://docs.microsoft.com/en-us/sql/relational-databases/json/format-query-results-as-json-with-for-json-sql-server?view=sql-server-ver15) clause.

For instance, let''s say we have a table with three columns: store, item, and quantity_sold.
We want to create a pivot table where each row is a store, and each column is an item.
We will return a set of json objects that look like this: `{"store":"Madrid", "Item1": 42, "Item2": 7, "Item3": 0}` 

```sql
SELECT ''table'' AS component;
with filled_data as (
  select
    stores.store, items.item,
    (select coalesce(sum(quantity_sold), 0) from store_sales where store=stores.store and item=items.item) as quantity 
  from (select distinct store from store_sales) as stores
  cross join (select distinct item from store_sales) as items
  order by stores.store, items.item
)
SELECT 
    ''dynamic'' AS component,
    JSON_PATCH( -- SQLite-specific, refer to your database documentation for the equivalent JSON functions
        JSON_OBJECT(''store'', store),
        JSON_GROUP_OBJECT(item, quantity)
    ) AS properties
FROM 
    filled_data
GROUP BY 
    store;
```

This will generate a table with the stores in the first column, and the items in the following columns, with the quantity sold in each store for each item.

', NULL
    ),
    (
    'table',
'## Using Action Buttons in a table.

### Preset Actions: `edit_url` & `delete_url`
Since edit and delete are common actions, the `table` component has dedicated `edit_url` and `delete_url` properties to add buttons for these actions.
The value of these properties should be a URL, containing the `{id}` placeholder that will be replaced by the value of the `_sqlpage_id` property for that row.

### Column with fixed action buttons

You may want to add custom action buttons to your table rows, for instance to view details, download a file, or perform a custom operation.
For this, the `table` component has a `custom_actions` top-level property that lets you define a column of buttons, each button defined by a name, an icon, a link, and an optional tooltip.

### Column with variable action buttons

The `table` component also supports the row level `_sqlpage_actions` column in your data table.
This is helpful if you want a more complex logic, for instance to disable a button on some rows, or to change the link or icon based on the row data.

> WARNING!
> If the number of array items in `_sqlpage_actions` is not consistent across all rows, the table may not render correctly.
> You can leave blank spaces by including an object with only the `name` property.

The table has a column of buttons, each button defined by the `custom_actions` column at the table level, and by the `_sqlpage_actions` property at the row level.

### `custom_actions` & `_sqlpage_actions` JSON properties.

Each button is defined by the following properties:
* `name`: sets the column header and the tooltip if no tooltip is provided,
* `tooltip`: text to display when hovering over the button,
* `link`: the URL to navigate to when the button is clicked, possibly containing the `{id}` placeholder that will be replaced by the value of the `_sqlpage_id` property for that row,
* `icon`: the tabler icon name or image link to display on the button

### Example using all of the above
'
    ,
    json('[
    {
        "component": "table",
        "edit_url": "/examples/show_variables.sql?action=edit&update_id={id}",
        "delete_url": "/examples/show_variables.sql?action=delete&delete_id={id}",
        "custom_actions": {
                "name": "history",
                "tooltip": "View Standard History",
                "link": "/examples/show_variables.sql?action=history&standard_id={id}",
                "icon": "history"
        }
    },
    {
        "name": "CalStd",
        "vendor": "PharmaCo",
        "Product": "P1234",
        "lot number": "T23523",
        "status": "Available",
        "expires on": "2026-10-13",
        "_sqlpage_id": 32,
        "_sqlpage_actions": [
            {
                "name": "View PDF",
                "tooltip": "View Presentation",
                "link": "https://sql-page.com/pgconf/2024-sqlpage-badass.pdf",
                "icon": "file-type-pdf"
            },
            {
                "name": "Action",
                "tooltip": "Set In Use",
                "link": "/examples/show_variables.sql?action=set_in_use&standard_id=32",
                "icon": "caret-right"
            }
        ]
    },
    {
        "name": "CalStd",
        "vendor": "PharmaCo",
        "Product": "P1234",
        "lot number": "T2352",
        "status": "In Use",
        "expires on": "2026-10-14",
        "_sqlpage_id": 33,
        "_sqlpage_actions": [
            {
                "name": "View PDF",
                "tooltip": "View Presentation",
                "link": "https://sql-page.com/pgconf/2024-sqlpage-badass.pdf",
                "icon": "file-type-pdf"
            },
            {
                "name": "Action",
                "tooltip": "Retire Standard",
                "link": "/examples/show_variables.sql?action=retire&standard_id=33",
                "icon": "test-pipe-off"
            }
        ]
    },
    {
        "name": "CalStd",
        "vendor": "PharmaCo",
        "Product": "P1234",
        "lot number": "A123",
        "status": "Discarded",
        "expires on": "2026-09-30",
        "_sqlpage_id": 31,
        "_sqlpage_actions": [
            {
                "name": "View PDF",
                "tooltip": "View Presentation",
                "link": "https://sql-page.com/pgconf/2024-sqlpage-badass.pdf",
                "icon": "file-type-pdf"
            },
            {
                "name": "Action"
            }
        ]
    }
]'
)
);



INSERT INTO component(name, icon, description) VALUES
    ('csv', 'download', 'Lets the user download data as a CSV file.
Each column from the items in the component will map to a column in the resulting CSV.

When `csv` is used as a **header component** (without a [shell](?component=shell)), it will trigger a download of the CSV file directly on page load.
If the csv file to download is large, we recommend using this approach.

When used inside a page (after calling the shell component), this will add a button to the page that lets the user download the CSV file.
The button will need to load the entire contents of the CSV file in memory, inside the browser, even if the user does not click on it.
If the csv file to download is large, we recommend using this component without a shell component in order to efficiently stream the data to the browser.
');

INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'csv', * FROM (VALUES
    -- top level
    ('separator', 'How individual values should be separated in the CSV. "," by default, set it to "\t" for tab-separated values.', 'TEXT', TRUE, TRUE),
    ('title', 'The text displayed on the download button.', 'TEXT', TRUE, FALSE),
    ('filename', 'The name of the file that should be downloaded (without the extension).', 'TEXT', TRUE, TRUE),
    ('icon', 'Name of the icon (from tabler-icons.io) to display in the button. Ignored when used as a header component.', 'ICON', TRUE, TRUE),
    ('color', 'Color of the button. Ignored when used as a header component.', 'COLOR', TRUE, TRUE),
    ('size', 'The size of the button (e.g., sm, lg). Ignored when used as a header component.', 'TEXT', TRUE, TRUE),
    ('bom', 'Whether to include a Byte Order Mark (a special character indicating the character encoding) at the beginning of the file. This is useful for Excel compatibility.', 'BOOLEAN', TRUE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('csv', '
### Header component: creating a CSV download URL

You can create a page that will trigger a download of the CSV file when the user visits it.
The contents will be streamed efficiently from the database to the browser, without being fully loaded in memory.
This makes it possible to download even very large files without overloading the database server, the web server, or the client''s browser.

#### `csv_download.sql`

```sql
select ''csv'' as component, ''example.csv'' as filename;
SELECT * FROM my_large_table;
```

#### `index.sql`
',
        json('[{"component":"button"}, {"title": "Download my data", "link": "/examples/csv_download.sql"}]')),
    ('csv', '
### CSV download button

This will generate a button to download the CSV file.
The button element itself will embed the entire contents of the CSV file, so it should not be used for large files.
The file will be entirely loaded in memory on the user''s browser, even if the user does not click on the button.
For smaller files, this is easier and faster to use than creating a separate SQL file to generate the CSV.
',
        json('[{"component":"csv", "title": "Download my data", "filename": "people", "icon": "file-download", "color": "green", "separator": ";", "bom": true}, '||
        '{"Forename": "Ophir", "Surname": "Lojkine", "Pseudonym": "lovasoa"},' ||
        '{"Forename": "Linus", "Surname": "Torvalds", "Pseudonym": "torvalds"}]'));


INSERT INTO component(name, icon, description) VALUES
    ('dynamic', 'repeat', 'Renders other components, given their properties as JSON.
If you are looking for a way to run FOR loops, to share similar code between pages of your site,
or to render multiple components for every line returned by your SQL query, then this is the component to use'); 

INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'dynamic', * FROM (VALUES
    -- top level
    ('properties', 'A json object or array that contains the names and properties of other components.', 'JSON', TRUE, TRUE)
) x;

INSERT INTO example(component, description, properties) VALUES
    ('dynamic', 'The dynamic component has a single top-level property named `properties`, but it can render any number of other components.
Let''s start with something simple to illustrate the logic. We''ll render a `text` component with two row-level properties: `contents` and `italics`. 
', json('[{"component":"dynamic", "properties": "[{\"component\":\"text\"}, {\"contents\":\"Hello, I am a dynamic component !\", \"italics\":true}]"}]')),
    ('dynamic', '
## Static component data stored in `.json` files

You can also store the data for a component in a `.json` file, and load it using the `dynamic` component.

This is particularly useful to create a single [shell](?component=shell#component) defining the site''s overall appearance and menus,
and displaying it on all pages without duplicating its code.

The following will load the data for a `shell` component from a file named `shell.json`,
using the [`sqlpage.read_file_as_text`](/functions.sql?function=read_file_as_text) function.

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
            {"link": "https//github.com/sqlpage/SQLPage/issues", "title": "Issues"},
            {"link": "https//github.com/sqlpage/SQLPage/discussions", "title": "Discussions"},
            {"link": "https//github.com/sqlpage/SQLPage", "title": "Github"}
        ]}
    ]
}
```
', NULL),
('dynamic', '
## Including another SQL file

To avoid repeating the same code on multiple pages, you can include another SQL file using the `dynamic` component
together with the [`sqlpage.run_sql`](/functions.sql?function=run_sql) function.

For instance, the following will include the file `shell.sql` at the top of the page,
and pass it a `$title` variable to display the page title.

```sql
SELECT ''dynamic'' AS component,
       sqlpage.run_sql(''shell.sql'', json_object(''title'', ''SQLPage documentation'')) AS properties;
```

And `shell.sql` could contain the following:

```sql
SELECT ''shell''     AS component,
    COALESCE($title, ''Default title'') AS title,
    ''/my_icon.png'' AS icon,
    ''products''     AS menu_item,
    ''about''        AS menu_item;
```

', NULL),
    ('dynamic', '
## Dynamic shell

On databases without a native JSON type (such as the default SQLite database),
you can use the `dynamic` component to generate
json data to pass to components that expect it.

This example generates a menu similar to the [shell example](?component=shell#component), but without using a native JSON type.

```sql
SELECT ''dynamic'' AS component, ''
{
    "component": "shell",
    "title": "SQLPage documentation",
    "link": "/",
    "menu_item": [
        {"link": "index.sql", "title": "Home"},
        {"title": "Community", "submenu": [
            {"link": "blog.sql", "title": "Blog"},
            {"link": "https//github.com/sqlpage/SQLPage/issues", "title": "Issues"},
            {"link": "https//github.com/sqlpage/SQLPage/discussions", "title": "Discussions"},
            {"link": "https//github.com/sqlpage/SQLPage", "title": "Github"}
        ]}
    ]
}
'' AS properties
```

[View the result of this query, as well as an example of how to generate a dynamic menu
based on the database contents](./examples/dynamic_shell.sql).
', NULL),
    ('dynamic', '
## Dynamic tables

The `dynamic` component can be used to generate [tables](?component=table#component) with dynamic columns,
using [your database''s JSON functions](/blog.sql?post=JSON%20in%20SQL%3A%20A%20Comprehensive%20Guide).

For instance, let''s say we have a table with three columns: user_id, name, and role.
We want to create a table where each row is a user, and each column is a role.
We will return a set of json objects that look like this: `{"name": "Alice", "admin": true, "editor": false, "viewer": true}`
```sql
SELECT ''table'' AS component;
SELECT ''dynamic'' AS component, 
    json_patch(
        json_object(''name'', name),
        json_object_agg(role, is_admin)
    ) AS properties
FROM users
GROUP BY name;
```
', NULL);

INSERT INTO component(name, icon, description) VALUES
    ('shell', 'layout-navbar', '
Customize the overall layout, header and footer of the page.

This is a special component that provides the page structure wrapping all other components on your page.

It generates the complete HTML document including the `<head>` section with metadata, title, and stylesheets,
as well as the navigation bar, main content area, and footer.

If you don''t explicitly call the shell component at the top of your SQL file, SQLPage will automatically
add a default shell component before your first try to display data on the page.

Use the shell component to customize page-wide settings like the page title, navigation menu, theme, fonts,
and to include custom visual styles (with CSS) or interactive behavior (with JavaScript) that should be loaded on the page.
');

INSERT INTO parameter(component, name, description_md, type, top_level, optional) SELECT 'shell', * FROM (VALUES
    ('favicon', 'The URL of the icon the web browser should display in bookmarks and tabs. This property is particularly useful if multiple sites are hosted on the same domain with different [``site_prefix``](https://github.com/sqlpage/SQLPage/blob/main/configuration.md#configuring-sqlpage).', 'URL', TRUE, TRUE),
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
    ('javascript_module', 'The URL of a javascript module in the ESM format (see javascript.info/modules)', 'URL', TRUE, TRUE),
    ('rss', 'The URL of an RSS feed to display in the top navigation bar. You can use the rss component to generate the field.', 'URL', TRUE, TRUE),
    ('image', 'The URL of an image to display next to the page title.', 'URL', TRUE, TRUE),
    ('social_image', 'The URL of the preview image that will appear in the Open Graph metadata when the page is shared on social media.', 'URL', TRUE, TRUE),
    ('icon', 'Name of an icon (from tabler-icons.io) to display next to the title in the navigation bar.', 'ICON', TRUE, TRUE),
    ('menu_item', 'Adds a menu item in the navigation bar at the top of the page. The menu item will have the specified name, and will link to as .sql file of the same name. A dropdown can be generated by passing a json object with a `title` and `submenu` properties.', 'TEXT', TRUE, TRUE),
    ('fixed_top_menu', 'Fixes the top bar with menu at the top (the top bar remains visible when scrolling long pages).', 'BOOLEAN', TRUE, TRUE),
    ('search_target', 'When this is set, a search field will appear in the top navigation bar, and load the specified sql file with an URL parameter named "search" when the user searches something.', 'TEXT', TRUE, TRUE),
    ('search_value', 'This value will be placed in the search field when "search_target" is set. Using the "$search" query parameter value will mirror the value that the user has searched for.', 'TEXT', TRUE, TRUE),
    ('search_placeholder', 'Customizes the placeholder text shown in the search input field. Replaces the default "Search" with text that better describes what users should search for.', 'TEXT', TRUE, TRUE),
    ('search_button', 'Customizes the text displayed on the search button. Replaces the default "Search" label with custom text that may better match your applications terminology or language.', 'TEXT', TRUE, TRUE),
    ('norobot', 'Forbids robots to save this page in their database and follow the links on this page. This will prevent this page to appear in Google search results for any query, for instance.', 'BOOLEAN', TRUE, TRUE),
    ('font', 'Specifies the font to be used for displaying text, which can be a valid font name from fonts.google.com or the path to a local WOFF2 font file starting with a slash (e.g., "/fonts/MyLocalFont.woff2").', 'TEXT', TRUE, TRUE),
    ('font_size', 'Font size on the page, in pixels. Set to 18 by default.', 'INTEGER', TRUE, TRUE),
    ('language', 'The language of the page. This can be used by search engines and screen readers to determine in which language the page is written.', 'TEXT', TRUE, TRUE),
    ('rtl', 'Whether the page should be displayed in right-to-left mode. Used to display Arabic, Hebrew, Persian, etc.', 'BOOLEAN', TRUE, TRUE),
    ('refresh', 'Number of seconds after which the page should refresh. This can be useful to display dynamic content that updates automatically.', 'INTEGER', TRUE, TRUE),
    ('sidebar', 'Whether the menu defined by menu_item should be displayed on the left side of the page instead of the top. Introduced in v0.27.', 'BOOLEAN', TRUE, TRUE),
    ('sidebar_theme', 'Used with sidebar property, It can be set to "dark" to exclusively set the sidebar into dark theme.', 'TEXT', TRUE, TRUE),
    ('theme', 'Set to "dark" to use a dark theme.', 'TEXT', TRUE, TRUE),
    ('footer', 'Muted text to display in the footer of the page. This can be used to display a link to the terms and conditions of your application, for instance. By default, shows "Built with SQLPage". Supports links with markdown.', 'TEXT', TRUE, TRUE),
    ('preview_image', 'The URL of an image to display as a link preview when the page is shared on social media', 'URL', TRUE, TRUE),
    ('navbar_title', 'The title to display in the top navigation bar. Used to display a different title in the top menu than the one that appears in the tab of the browser.', 'TEXT', TRUE, TRUE),
    ('target', 'Where the menu items should open: "_blank" for a new tab, "_self" for the same tab, "_parent" for the parent frame, or "_top" for the full body of the window. Set it inside a "menu_item" json object; it has no effect when set directly on the shell.', 'TEXT', TRUE, TRUE),
    ('class', 'class attribute added to the page''s html element. It can be used to apply custom styling to the whole page through css.', 'TEXT', TRUE, TRUE)
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
            "title": "SQLPage: SQL websites",
            "icon": "database",
            "link": "/",
            "menu_item": [
                {"title": "About", "submenu": [
                    {"link": "/safety.sql", "title": "Security", "icon": "lock"},
                    {"link": "/performance.sql", "title": "Performance", "icon": "bolt"},
                    {"link": "//github.com/sqlpage/SQLPage/blob/main/LICENSE.txt", "title": "License", "icon": "file-text"},
                    {"link": "/blog.sql", "title": "Articles", "icon": "book"}
                ]},
                {"title": "Examples", "submenu": [
                    {"link": "/examples/tabs/", "title": "Tabs", "icon": "layout-navbar"},
                    {"link": "/examples/layouts.sql", "title": "Layouts", "icon": "layout"},
                    {"link": "/examples/multistep-form", "title": "Forms", "icon": "edit"},
                    {"link": "/examples/handle_picture_upload.sql", "title": "File uploads", "icon": "upload"},
                    {"link": "/examples/authentication/", "title": "Password protection", "icon": "password-user"},
                    {"link": "//github.com/sqlpage/SQLPage/blob/main/examples/", "title": "All examples & demos", "icon": "code"}
                ]},
                {"title": "Community", "submenu": [
                    {"link": "/blog.sql", "title": "Blog", "icon": "book"},
                    {"link": "//github.com/sqlpage/SQLPage/issues", "title": "Report a bug", "icon": "bug"},
                    {"link": "//github.com/sqlpage/SQLPage/discussions", "title": "Discussions", "icon": "message"},
                    {"link": "//github.com/sqlpage/SQLPage", "title": "Github", "icon": "brand-github"}
                ]},
                {"title": "Documentation", "submenu": [
                    {"link": "/your-first-sql-website", "title": "Getting started", "icon": "book"},
                    {"link": "/components.sql", "title": "All Components", "icon": "list-details"},
                    {"link": "/functions.sql", "title": "SQLPage Functions", "icon": "math-function"},
                    {"link": "/extensions-to-sql", "title": "Extensions to SQL", "icon": "cube-plus"},
                    {"link": "/custom_components.sql", "title": "Custom Components", "icon": "puzzle"},
                    {"link": "//github.com/sqlpage/SQLPage/blob/main/configuration.md#configuring-sqlpage", "title": "Configuration", "icon": "settings"}
                ]},
                {"title": "Search", "link": "/search"}
            ],
            "layout": "boxed",
            "language": "en-US",
            "description": "Go from SQL queries to web applications in an instant.",
            "preview_image": "https://sql-page.com/sqlpage_social_preview.webp",
            "theme": "dark",
            "font": "Poppins",
            "javascript": [
                "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
                "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
                "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
                "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js",
                "/assets/highlightjs-launch.js"
            ],
            "css": "/assets/highlightjs-and-tabler-theme.css",
            "footer": "[Built with SQLPage](https://github.com/sqlpage/SQLPage/tree/main/examples/official-site)"
        }]')),
    ('shell', '
This example shows how to set menu items as active in the navigation, so that they are highlighted in the nav bar.

In this example you can see that two menu items are created, "Home" and "About" and the "Home" tab is marked as active.
',
     json('[{
            "component": "shell",
            "title": "SQLPage: SQL websites",
            "icon": "database",
            "link": "/",
            "menu_item": [
                {"title": "Home", "active": true},
                {"title": "About"}
            ]
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
            {"link": "/blog.sql", "title": "Blog"},
            {"link": "//github.com/sqlpage/SQLPage", "title": "Github"}
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
set role = (
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
    ''{"title":"Examples","image": "https://upload.wikimedia.org/wikipedia/en/6/6b/Terrestrial_globe.svg","submenu":[{"link":"/examples/tabs/","title":"Tabs","image": "https://upload.wikimedia.org/wikipedia/en/6/6b/Terrestrial_globe.svg"},{"link":"/examples/layouts.sql","title":"Layouts"}]}'' AS menu_item,
    ''{"title":"Examples","size":"sm","image": "https://upload.wikimedia.org/wikipedia/en/6/6b/Terrestrial_globe.svg","submenu":[{"link":"/examples/tabs/","title":"Tabs","image": "https://upload.wikimedia.org/wikipedia/en/6/6b/Terrestrial_globe.svg"},{"link":"/examples/layouts.sql","title":"Layouts"}]}'' AS menu_item,
    ''Official [SQLPage](https://sql-page.com) documentation'' as footer;
```
', NULL),
    ('shell', '
### Returning custom HTML, XML, plain text, or other formats

Use `shell-empty` to opt out of SQLPage''s component system and return raw data directly.

By default, SQLPage wraps all your content in a complete HTML page with navigation and styling. 
The `shell-empty` component tells SQLPage to skip this HTML wrapper and return only the raw content you specify.

Use it to create endpoints that return things like
 - XML (for JSON, use the [json](?component=json) component)
 - plain text or markdown content (for instance for consumption by LLMs)
 - a custom data format you need

When using `shell-empty`, you should use the [http_header](component.sql?component=http%5Fheader) component first
to set the correct [content type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type) (like `application/json` or `application/xml`).
',
     json('[
        {
            "component":"http_header", 
            "Content-Type":"application/xml"
        },
        {
            "component":"shell-empty", 
            "contents": "<?xml version=\"1.0\"?>\n <user>\n   <account>42</account>\n   <login>john.doe</login>\n </user>"
        }
    ]')
    ),
    ('shell','
### Generate your own HTML
If you generate your own HTML from a SQL query, you can also use the `shell-empty` component to include it in a page.
This is useful when you want to generate a snippet of HTML that can be dynamically included in a larger page.
Make sure you know what you are doing, and be careful to escape the HTML properly,
as you are stepping out of the safe SQLPage framework and into the wild world of HTML.

In this scenario, you can use the `html` property, which serves as an alias for the `contents` property. 
This property improves code readability by clearly indicating that you are generating HTML. 
Since SQLPage returns HTML by default, there is no need to specify the content type in the HTTP header.
',
    json('[{"component":"shell-empty", "html": "<!DOCTYPE html>\n<html>\n<head>\n  <title>My page</title>\n</head>\n<body>\n  <h1>My page</h1>\n</body>\n</html>"}]'));
