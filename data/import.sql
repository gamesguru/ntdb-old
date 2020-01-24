-- Use common schema
SET search_path TO inutra;
---------------------------
-- Import data
---------------------------
-- bfdb
\copy "Nutrient" FROM 'tmp/bfdb/Nutrient.csv' WITH csv HEADER;
\copy "Products" FROM 'tmp/bfdb/Products.csv' WITH csv HEADER;
\copy "Serving_Size" FROM 'tmp/bfdb/Serving_Size.csv' WITH csv HEADER;
