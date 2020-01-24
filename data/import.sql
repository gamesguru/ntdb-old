-- Use common schema
SET search_path TO inutra;

---------------------------
-- Import data
---------------------------

-- usda
\copy "FD_GROUP" FROM 'tmp/usda/FD_GROUP.csv' WITH csv HEADER;
\copy "FOOD_DES" FROM 'tmp/usda/FOOD_DES.csv' WITH csv HEADER;
\copy "NUT_DATA" FROM 'tmp/usda/NUT_DATA.csv' WITH csv HEADER;
\copy "NUTR_DEF" FROM 'tmp/usda/NUTR_DEF.csv' WITH csv HEADER;
\copy "WEIGHT" FROM 'tmp/usda/WEIGHT.csv' WITH csv HEADER;
