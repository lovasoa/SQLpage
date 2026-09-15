INSERT INTO component(name, icon, description, introduced_in_version) VALUES
    ('media', 'device-tv', 'A HTML5 media component for playing video or audio files.

To gain a better understanding of all the available options, we recommend reading the articles on [developer.mozilla.org](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Client-side_APIs/Video_and_audio_APIs) about the `<video>` and `<audio>` elements.
', '0.47.0');

-- https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Structuring_content/HTML_video_and_audio

INSERT INTO parameter(component, name, description, type, top_level, optional) SELECT 'media', * FROM (VALUES
    -- Top-level parameters
    ('type','Type of the media. It is used to determine which HTML component will be used to render the item (e.g., video, audio).','TEXT',TRUE,FALSE),
    ('center','If true, the component is centered in the page. Default is false.','BOOLEAN',TRUE,TRUE),
    ('title','Title of the component. It is displayed above the component.','TEXT',TRUE,TRUE),
    ('description','Description of the component. It is displayed below the component.','TEXT',TRUE,TRUE),
    ('description_md','Description of the component in markdown format. It is displayed below the component.','TEXT',TRUE,TRUE),
    ('fallback_text','Fallback text displayed when the media cannot be played.','TEXT',TRUE,TRUE),
    ('controls','If true, the media player controls are displayed. Default is true.','BOOLEAN',TRUE,TRUE),
    ('autoplay','If true, the media starts playing automatically. Default is false.','BOOLEAN',TRUE,TRUE),
    ('loop','If true, the media loops when it reaches the end. Default is false.','BOOLEAN',TRUE,TRUE),
    ('muted','If true, the media is muted. Default is false.','BOOLEAN',TRUE,TRUE),
    ('preload','Indicates how the media should be loaded when the page loads (e.g., none, metadata, auto).','TEXT',TRUE,TRUE),
    ('loading','Indicates how the media should be loaded when the page loads (e.g., eager, lazy).','TEXT',TRUE,TRUE),
    ('crossorigin','Indicates how the media should be loaded when the page loads (e.g., anonymous, use-credentials).','TEXT',TRUE,TRUE),
    ('controls_list','Indicates which controls should be displayed in the media player (e.g., nofullscreen, nodownload, noremoteplayback, noplaybackrate).','TEXT',TRUE,TRUE),
    ('disable_remote_playback','If true, the media cannot be played on remote devices. Default is false.','BOOLEAN',TRUE,TRUE),
    ('width','Width of the media player in pixels (video only).','INTEGER',TRUE,TRUE),
    ('poster','URL of the poster image displayed before the media starts playing (video only).','TEXT',TRUE,TRUE),
    ('plays_inline','If true, the media is played inline on mobile devices (video only). Default is false.','BOOLEAN',TRUE,TRUE),
    ('disable_picture_in_picture','If true, the media cannot be played in picture-in-picture mode (video only). Default is false.','BOOLEAN',TRUE,TRUE),
    ('tracks','List of tracks associated with the media (video only). Each track is represented as a JSON object with the following properties: kind, src, srclang, label, default.','JSON',TRUE,TRUE),
    -- Item-level parameters
    ('src','URL of the media file. Providing multiple formats ensures that the video can be played across different browsers and devices, as each may support different video codecs.','TEXT',FALSE,FALSE),
    ('type','MIME type of the media file (e.g., video/mp4, video/webm, audio/mpeg, audio/ogg).','TEXT',FALSE,TRUE),
    ('codecs','Comma-separated list of codecs used in the media file. It is used to determine if the media can be played in the browser.','TEXT',FALSE,TRUE)
) x;

-- Insert example(s) for the component
INSERT INTO example(component, description, properties)
VALUES (
    'media',
    'A video player featuring a title and playback controls.',
    JSON(
        '[
            {
                "component": "media",
                "type": "video",
                "title": "SQLPage Introduction Video",
                "width": 480,
                "controls": true
            },
            {
                "src": "sqlpage_introduction_video.webm",
                "type": "video/webm"
            }
        ]'
    )),
    ('media',
    'A centered video player with a description, autoplay and loop options, but no controls.',
    JSON(
        '[
            {
                "component": "media",
                "type": "video",
                "center": true,
                "autoplay": true,
                "loop": true,
                "description": "SQLPage Introduction Video",
                "width": 480
            },
            {
                "src": "sqlpage_introduction_video.webm",
                "type": "video/webm"
            }
        ]'
    )),
    ('media',
    'A music player with a description and controls.',
    JSON(
        '[
            {
                "component": "media",
                "type": "audio",
                "controls": true,
                "description": "An AI-generated MP3 audio file."
            },
            {
                "src": "assets/mp3_file.mp3",
                "type": "audio/mpeg"
            }
        ]'
    ));