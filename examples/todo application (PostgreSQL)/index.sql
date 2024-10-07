select 'dynamic' as component, sqlpage.run_sql('shell.sql') as properties;

select 'list' as component,
    'Todo' as title,
    'No todo yet...' as empty_title;

select 
    title,
    'todo_form.sql?todo_id=' || id as edit_link,
    'delete.sql?todo_id=' || id as delete_link
from todos;

select 
    'button' as component,
    'center' as justify;
select 
    'todo_form.sql'     as link,
    'green' as color,
    'Add new todo'  as title,
    'circle-plus'  as icon;
select 
    '/csv_attachment.sql' as link,
    'Download'  as title,
    'download' as icon;