-- Use common schema
DROP SCHEMA inutra CASCADE;
CREATE SCHEMA inutra;
SET search_path TO inutra;

-- Create tables
\i csv/usda.sql
