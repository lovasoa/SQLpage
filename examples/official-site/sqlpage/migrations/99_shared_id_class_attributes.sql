INSERT INTO parameter(component, top_level, name, description, type, optional) 
SELECT *, 'id', 'id attribute added to the container in HTML. It can be used to target this item through css or for scrolling to this item through links (use "#id" in link url).', 'TEXT', TRUE
FROM (VALUES
    ('alert', TRUE),
    ('breadcrumb', TRUE),
    ('chart', TRUE),
    ('code', TRUE),
    ('csv', TRUE),
    ('datagrid', TRUE),
    ('hero', TRUE),
    ('list', TRUE),
    ('list', FALSE),
    ('map', TRUE),
    ('tab', FALSE),
    ('table', TRUE),
    ('timeline', TRUE),
    ('timeline', FALSE),
    ('title', TRUE),
    ('tracking', TRUE),
    ('text', TRUE),
    ('carousel', TRUE),
    ('image',TRUE)
);

INSERT INTO parameter(component, top_level, name, description, type, optional) 
SELECT *, 'id', 'id attribute injected as an anchor in HTML. It can be used for scrolling to this item through links (use "#id" in link url). Added in v0.18.0.', 'TEXT', TRUE
FROM (VALUES
    ('steps', TRUE)
);

INSERT INTO parameter(component, top_level, name, description, type, optional) 
SELECT *, 'class', 'class attribute added to the container in HTML. It can be used to apply custom styling to this item through css. Added in v0.18.0.', 'TEXT', TRUE
FROM (VALUES
    ('alert', TRUE),
    ('breadcrumb', TRUE),
    ('button', TRUE),
    ('card', FALSE),
    ('chart', TRUE),
    ('code', TRUE),
    ('csv', TRUE),
    ('datagrid', TRUE),
    ('divider', TRUE),
    ('form', TRUE),
    ('list', TRUE),
    ('list', FALSE),
    ('map', TRUE),
    ('tab', FALSE),
    ('table', TRUE),
    ('timeline', TRUE),
    ('timeline', FALSE),
    ('title', TRUE),
    ('tracking', TRUE),
    ('carousel', TRUE),
    ('image', TRUE)
);

