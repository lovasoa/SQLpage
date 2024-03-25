-- Documentation for the container component
INSERT INTO component (name, description, icon, introduced_in_version) VALUES (
    'container',
    'A low level component to create a dedicated DOM area to dynamically add, modify or delete elements. To this, you can use Vanilla JavaScript or using dedicated framework as JQuery. The container component is built from a DIV element. An identifier is mandatory to access the container content with the method getElementById() for example. This component is useful for inserting the result of an AJAX request in the page.',
    'select-all',
    '0.20.0'
);

INSERT INTO parameter (component,name,description,type,top_level,optional) VALUES (
    'container',
    'class',
    'class attribute added to the container in HTML. It can be used to apply custom styling to this item through css.',
    'TEXT',
    TRUE,
    TRUE
),(
    'container',
    'id',
    'A unique identifier for the container, which can then be used to select and manage the div content with Javascript code.',
    'TEXT',
    TRUE,
    FALSE
),(
    'container',
    'border',
    'Whether a border is draw around the container component.',
    'BOOLEAN',
    TRUE,
    TRUE
);

-- Insert example(s) for the component
INSERT INTO example(component, description, properties) VALUES (
    'container',
    'Insert an empty div element that can be access with JavaScript.',
    JSON(
        '[
            {"component":"container","id":"list","border":true}
        ]'
    )
);