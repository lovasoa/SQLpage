-- Insert the 'variables' function into sqlpage_functions table
INSERT INTO sqlpage_functions (
    "name",
    "introduced_in_version",
    "icon",
    "description_md"
)
VALUES (
    'uploaded_file_path',
    '0.17.0',
    'upload',
    'Returns the path to a temporary file containing the contents of an uploaded file.

## Example: handling a picture upload

### Making a form

```sql
select ''form'' as component, ''handle_picture_upload.sql'' as action;
select ''myfile'' as name, ''file'' as type, ''Picture'' as label;
select ''title'' as name, ''text'' as type, ''Title'' as label;
```

### Handling the form response

In `handle_picture_upload.sql`, one can process the form results like this:

```sql
insert into pictures (title, path) values (:title, sqlpage.read_file_as_data_url(sqlpage.uploaded_file_path(''myfile'')));
```
'
),
(
    'uploaded_file_mime_type',
    '0.17.0',
    'file-settings',
    'Returns the MIME type of an uploaded file.

## Example: handling a picture upload

When letting the user upload a picture, you may want to check that the uploaded file is indeed an image.

```sql
select ''redirect'' as component, 
       ''invalid_file.sql'' as link
where sqlpage.uploaded_file_mime_type(''myfile'') not like ''image/%'';
```

In `invalid_file.sql`, you can display an error message to the user:

```sql
select ''alert'' as component, ''Error'' as title,
    ''Invalid file type'' as description,
    ''alert-circle'' as icon, ''red'' as color;
```

## Example: white-listing file types

You could have a database table containing the allowed MIME types, and check that the uploaded file is of one of those types:

```sql
select ''redirect'' as component, 
       ''invalid_file.sql'' as link
where sqlpage.uploaded_file_mime_type(''myfile'') not in (select mime_type from allowed_mime_types);
```
'
);

INSERT INTO sqlpage_function_parameters (
    "function",
    "index",
    "name",
    "description_md",
    "type"
)
VALUES (
    'uploaded_file_path',
    1,
    'name',
    'Name of the file input field in the form.',
    'TEXT'
), 
(
    'uploaded_file_path',
    2,
    'allowed_mime_type',
    'Makes the function return NULL if the uploaded file is not of the specified MIME type.
    If omitted, any MIME type is allowed.
    This makes it possible to restrict the function to only accept certain file types.',
    'TEXT'
),
(
    'uploaded_file_mime_type',
    1,
    'name',
    'Name of the file input field in the form.',
    'TEXT'
)
;
