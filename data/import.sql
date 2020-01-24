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
\copy "CONVERSION FACTOR" FROM 'tmp/cnf/CONVERSION FACTOR.csv' WITH csv HEADER;
\copy "FOOD GROUP" FROM 'tmp/cnf/FOOD GROUP.csv' WITH csv HEADER encoding 'ISO_8859_5';
\copy "FOOD NAME" FROM 'tmp/cnf/FOOD NAME.csv' WITH csv HEADER encoding 'ISO_8859_5';
\copy "MEASURE NAME" FROM 'tmp/cnf/MEASURE NAME.csv' WITH csv HEADER encoding 'ISO_8859_5';
\copy "NUTRIENT AMOUNT" FROM 'tmp/cnf/NUTRIENT AMOUNT.csv' WITH csv HEADER;
\copy "NUTRIENT NAME" FROM 'tmp/cnf/NUTRIENT NAME.csv' WITH csv HEADER encoding 'ISO_8859_5';

-- ofdb
\copy "en.openfoodfacts.org.products-trunc" FROM 'tmp/ofdb/en.openfoodfacts.org.products.csv' WITH csv HEADER delimiter E'\t';

-- usda
\copy "FD_GROUP" FROM 'tmp/usda/FD_GROUP.csv' WITH csv HEADER;
\copy "FOOD_DES" FROM 'tmp/usda/FOOD_DES.csv' WITH csv HEADER;
\copy "NUT_DATA" FROM 'tmp/usda/NUT_DATA.csv' WITH csv HEADER;
\copy "NUTR_DEF" FROM 'tmp/usda/NUTR_DEF.csv' WITH csv HEADER;
\copy "WEIGHT" FROM 'tmp/usda/WEIGHT.csv' WITH csv HEADER;
