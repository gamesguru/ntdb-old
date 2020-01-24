-- Use common schema
SET search_path TO inutra;

---------------------------
-- Import data
---------------------------

-- bfdb
\copy "Nutrient" FROM 'tmp/bfdb/Nutrient.csv' WITH csv HEADER;
\copy "Products" FROM 'tmp/bfdb/Products.csv' WITH csv HEADER;
\copy "Serving_Size" FROM 'tmp/bfdb/Serving_Size.csv' WITH csv HEADER;

-- cnf
\copy "CONVERSION FACTOR" FROM 'tmp/bfdb/CONVERSION FACTOR.csv' WITH csv HEADER;
\copy "FOOD GROUP" FROM 'tmp/bfdb/FOOD GROUP.csv' WITH csv HEADER;
\copy "FOOD NAME" FROM 'tmp/bfdb/FOOD NAME.csv' WITH csv HEADER;
\copy "MEASURE NAME" FROM 'tmp/bfdb/MEASURE NAME.csv' WITH csv HEADER;
\copy "NUTRIENT AMOUNT" FROM 'tmp/bfdb/NUTRIENT AMOUNT.csv' WITH csv HEADER;
\copy "NUTRIENT NAME" FROM 'tmp/bfdb/NUTRIENT NAME.csv' WITH csv HEADER;

-- ofdb
\copy "en.openfoodfacts.org.products-trunc" FROM 'tmp/bfdb/en.openfoodfacts.org.products.csv' WITH csv HEADER;

-- usda
\copy "FD_GROUP" FROM 'tmp/bfdb/FD_GROUP.csv' WITH csv HEADER;
\copy "FOOD_DES" FROM 'tmp/bfdb/FOOD_DES.csv' WITH csv HEADER;
\copy "NUT_DATA" FROM 'tmp/bfdb/NUT_DATA.csv' WITH csv HEADER;
\copy "NUTR_DEF" FROM 'tmp/bfdb/NUTR_DEF.csv' WITH csv HEADER;
\copy "WEIGHT" FROM 'tmp/bfdb/WEIGHT.csv' WITH csv HEADER;
