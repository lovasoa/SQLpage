-- Disable actix-web compression middleware:
--    https://github.com/actix/actix-web/issues/3410
SELECT 'http_header' AS component, 'Identity' AS "Content-Encoding";

SELECT 'shell' AS component, 'light' AS theme;

-- can disable the spinner to show only progress bar
SELECT 'loader-start' AS component,  '' AS spinner;

SELECT 'progress' AS component,
  NULL AS percent,
  'sm' AS size,
  'yellow' AS color,
  'Working on it' AS stage;
SELECT sqlpage.fetch('https://example.com');

SELECT 'loader-stop' AS component;

SELECT 'text' AS component, 'Processing complete.' AS contents;
