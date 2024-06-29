-- Disable actix-web compression middleware:
--    https://github.com/actix/actix-web/issues/3410
SELECT 'http_header' AS component, 'Identity' AS "Content-Encoding";

SELECT 'shell' AS component, 'dark' AS theme;

SELECT 'loader-start' AS component,
  -- pick from the tabler spinners: https://tabler.io/docs/components/spinners
  "spinner-border" spinner,
  "sm" AS size,
  "red" AS color;

SELECT 'progress' AS component,
  'sm' AS size,
  'yellow' AS color,
  '0' AS percent,
  'Fething data' AS stage;
SELECT sqlpage.fetch('https://example.com');

/* percent property is optional */
SELECT 'progress' AS component,
  NULL AS percent,
  'sm' AS size,
  'yellow' AS color,
  'Doing something' AS stage;
SELECT sqlpage.fetch('https://example.com');

/* stage property is optional */
SELECT 'progress' AS component,
  'sm' AS size,
  'yellow' AS color,
  '40' AS percent;
SELECT sqlpage.fetch('https://example.com');

/* multiple rows */
SELECT 'progress' AS component, 'sm' AS size, 'yellow' AS color;
SELECT '70' AS percent, 'Fetching data' AS stage
SELECT sqlpage.fetch('https://example.com');
SELECT '80' AS percent, 'Fetching more data' AS stage;
SELECT sqlpage.fetch('https://example.com');
SELECT '90' AS percent, 'Fetching again' AS stage;
SELECT sqlpage.fetch('https://example.com');

SELECT '100' AS percent;

SELECT 'loader-stop' AS component;

SELECT 'text' AS component,
  'It works!' AS title,
  TRUE AS center,
  'Page is loaded.' AS contents;

SELECT 'button' AS component;
SELECT 'Go' AS title, './go.sql' AS link;

-- can use progress on it's own
SELECT 'progress' AS component, 'sm' AS size, 'Waiting for user' AS stage;
