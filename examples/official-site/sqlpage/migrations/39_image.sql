-- Documentation for the title component
INSERT INTO component (name, description, icon, introduced_in_version) VALUES (
    'image',
    'The image component embeds an image into the page.',
    'photo',
    '0.20.0'
);

INSERT INTO parameter (component,name,description,type,top_level,optional) VALUES (
    'image',
    'width',
    'Width of the component, between 1 and 12. Default is 12.',
    'NUMBER',
    TRUE,
    TRUE
),(
    'image',
    'center',
    'Whether to center the image.',
    'BOOLEAN',
    TRUE,
    TRUE
),(
    'image',
    'description',
    'A short paragraph.',
    'TEXT',
    TRUE,
    TRUE   
),(
    'image',
    'link',
    'The URL to which the image should navigate when clicked.',
    'URL',
    TRUE,
    TRUE   
),(
    'image',
    'image',
    'The URL (absolute or relative) of an image to display.',
    'URL',
    TRUE,
    FALSE   
),(
    'image',
    'cross_origin',
    'Indicates if the fetching of the image must be done using a CORS request (e.g., anonymous, use-credentials)',
    'TEXT',
    TRUE,
    TRUE   
),(
    'image',
    'decoding',
    'Provides a hint to the browser when it should perform image decoding (e.g., sync, async, auto)',
    'TEXT',
    TRUE,
    TRUE   
),(
    'image',
    'fetch_priority',
    'Set the relative priority to use when fetching the image (e.g., high, low, auto)',
    'TEXT',
    TRUE,
    TRUE 
),(
    'image',
    'loading',
    'Indicates how the browser should load the image (e.g., eager, lazy)',
    'TEXT',
    TRUE,
    TRUE   
),(
    'image',
    'referrer_policy',
    'Indicates which referrer to use when fetching the resource (e.g., no-referrer, no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url)',
    'TEXT',
    TRUE,
    TRUE   
),(
    'image',
    'sizes',
    'Indicates a set of source sizes by one or more strings separated by commas.',
    'TEXT',
    TRUE,
    TRUE   
),(
    'image',
    'src_set',
    'Set possible image sources for the user agent to use.',
    'TEXT',
    TRUE,
    TRUE   
),(
    'image',
    'caption',
    'Indicates a legend that describes the image',
    'TEXT',
    TRUE,
    TRUE   
);

-- Insert example(s) for the component
INSERT INTO example(component, description, properties) VALUES (
    'image',
    'Displays a centered image with a clickable link, a legend and a description.',
    JSON(
        '[
            {
                "component":"image",
                "image":"https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Cat_close-up_2004_b.jpg/1280px-Cat_close-up_2004_b.jpg",
                "caption":"The cat (Felis catus) is the only domesticated species in the family Felidae.",
                "description":"A cute cat",
                "width": 4,
                "center": true,
                "link": "#"
            }
        ]'
    )
);