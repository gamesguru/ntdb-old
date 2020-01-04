-- Run from parent directory, e.g. `../`

\! echo '\nBEGIN: [rebuild.sql]';

DROP SCHEMA data CASCADE;
DROP SCHEMA users CASCADE;
DROP SCHEMA shop CASCADE;

\i ./sql/tables.sql
\i ./sql/functions.sql
\i ./sql/import.sql
