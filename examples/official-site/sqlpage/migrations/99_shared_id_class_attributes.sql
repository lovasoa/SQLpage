-- Every component whose `id` and `class` properties behave in the ordinary way
-- is documented from the lists below, so that the wording stays identical
-- across components and so that the (component, top_level, name) primary key
-- of `parameter` is not violated.
--
-- A handful of components deliberately document `id` or `class` in their own
-- migration instead, because the generic wording would be wrong for them:
-- `modal` (`id` is required, and is what a button targets), `form` (`id` is
-- what an outside submit button references), `foldable` (top level and item
-- level mean different things) and `button` (`id` lands on each button, not on
-- the container). Do not duplicate those here.

INSERT INTO parameter(component, top_level, name, description, type, optional)
SELECT *, 'id', 'id attribute added to the container in HTML. It can be used to target this item through css or for scrolling to this item through links (use "#id" in link url).', 'TEXT', TRUE
FROM (VALUES
    ('alert', TRUE),
    ('big_number', TRUE),
    ('big_number', FALSE),
    ('breadcrumb', TRUE),
    ('card', FALSE),
    ('chart', TRUE),
    ('code', TRUE),
    ('csv', TRUE),
    ('datagrid', TRUE),
    ('datagrid', FALSE),
    ('empty_state', TRUE),
    ('hero', TRUE),
    ('list', TRUE),
    ('list', FALSE),
    ('map', TRUE),
    ('tab', TRUE),
    ('tab', FALSE),
    ('table', TRUE),
    ('timeline', TRUE),
    ('timeline', FALSE),
    ('title', TRUE),
    ('toast', TRUE),
    ('tracking', TRUE),
    ('text', TRUE),
    ('carousel', TRUE),
    ('login', TRUE),
    ('pagination', TRUE),
    ('facet', TRUE),
    ('media', TRUE)
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
    ('big_number', TRUE),
    ('big_number', FALSE),
    ('breadcrumb', TRUE),
    ('button', TRUE),
    ('card', TRUE),
    ('card', FALSE),
    ('chart', TRUE),
    ('code', TRUE),
    ('csv', TRUE),
    ('datagrid', TRUE),
    ('divider', TRUE),
    ('empty_state', TRUE),
    ('form', TRUE),
    ('list', TRUE),
    ('list', FALSE),
    ('map', TRUE),
    ('tab', TRUE),
    ('tab', FALSE),
    ('table', TRUE),
    ('timeline', TRUE),
    ('timeline', FALSE),
    ('title', TRUE),
    ('toast', TRUE),
    ('tracking', TRUE),
    ('carousel', TRUE),
    ('login', TRUE),
    ('pagination', TRUE),
    ('facet', TRUE),
    ('media',TRUE)
);
