-- Use common schema
SET search_path TO inutra;

---------------------------
-- Import data
---------------------------

-- usda
\copy "FD_GROUP" FROM 'csv/usda/FD_GROUP.csv' WITH csv HEADER;
\copy "FOOD_DES" FROM 'csv/usda/FOOD_DES.csv' WITH csv HEADER;
\copy "NUT_DATA" FROM 'csv/usda/NUT_DATA.csv' WITH csv HEADER;
\copy "NUTR_DEF" FROM 'csv/usda/NUTR_DEF.csv' WITH csv HEADER;
\copy "WEIGHT" FROM 'csv/usda/WEIGHT.csv' WITH csv HEADER;
