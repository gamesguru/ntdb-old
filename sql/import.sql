
\! echo '\nBEGIN: [import.sql]';



-- Import DATA_SRCs --
\! echo '[DATA SRC IDs]';
\copy data.data_src FROM './data/DATA_SRC.csv' WITH csv HEADER;
SELECT pg_catalog.setval(pg_get_serial_sequence('data.data_src', 'data_src_id'), (SELECT MAX(data_src_id) FROM data.data_src));

-- -- Import EXERCISE data --
-- \! echo '[EXERCISE DATA]';
-- \copy users.exercises (exercise_name, cals_per_min, data_src_id) FROM ../data/exercises/harvard150.csv WITH (FORMAT csv, HEADER);

-- -- Import BIOMETRIC data --
-- \! echo '[BIOMETRIC DATA]';
-- \copy users.biometrics (biometric_name, units) FROM ../data/biometrics.csv WITH (FORMAT csv, HEADER);



-- USDA --
\! echo '[USDA]';
\copy data.fdgrp FROM './data/FD_GROUP.csv' WITH csv HEADER;
SELECT pg_catalog.setval(pg_get_serial_sequence('data.fdgrp', 'fdgrp_id'), (SELECT MAX(fdgrp_id) FROM data.fdgrp));
-- TODO - investigate (x, y).. why not import/export all rows
\copy data.tag_id (tag_desc, approved) FROM './data/TAGS.csv' WITH csv HEADER;
SELECT pg_catalog.setval(pg_get_serial_sequence('data.tag_id', 'tag_id'), (SELECT MAX(tag_id) FROM data.tag_id));

\copy data.nutr_def FROM './data/NUTR_DEF.csv' WITH (FORMAT csv, HEADER, FORCE_NULL(rda, user_id));
SELECT pg_catalog.setval(pg_get_serial_sequence('data.nutr_def', 'nutr_no'), (SELECT MAX(nutr_no) FROM data.nutr_def));

-- TODO - investigate (x, y).. why not import/export all rows
\copy data.food_des (food_id, fdgrp_id, data_src_id, long_desc, manufacturer, ref_desc, refuse) FROM './data/usda/FOOD_DES.csv' WITH csv HEADER;
SELECT pg_catalog.setval(pg_get_serial_sequence('data.food_des', 'food_id'), (SELECT MAX(food_id) FROM data.food_des));

\copy data.nut_data FROM './data/usda/NUT_DATA.csv' WITH csv HEADER;
\copy data.nut_data FROM './data/usda/fields/ALA_5.csv' WITH csv HEADER;
\copy data.nut_data FROM './data/usda/fields/EpaDha_6.csv' WITH csv HEADER;

\copy data.serving_id FROM './data/SERVING_ID.csv' WITH csv HEADER;
SELECT pg_catalog.setval(pg_get_serial_sequence('data.serving_id', 'msre_id'), (SELECT MAX(msre_id) FROM data.serving_id));
\copy data.serving FROM './data/usda/WEIGHT.csv' WITH csv HEADER;

-- -- CNF --
-- \! echo '[CNF]';
-- \copy data.food_des (food_id, fdgrp_id, data_src_id, long_desc) FROM ../data/cnf/FOOD_DES.csv WITH (FORMAT csv, HEADER);
-- \copy data.nut_data FROM ../data/cnf/NUT_DATA.csv WITH (FORMAT csv, HEADER);

-- -- BFDB --
-- \! echo '[BFDB]';
-- \copy data.food_des (food_id, fdgrp_id, data_src_id, long_desc, gtin_UPC, manufacturer, ingredients) FROM ../data/bfdb/FOOD_DES.csv WITH (FORMAT csv, HEADER);
-- \copy data.nut_data FROM ../data/bfdb/NUT_DATA.csv WITH (FORMAT csv, HEADER);
-- \copy data.serving FROM ../data/bfdb/WEIGHT.csv WITH (FORMAT csv, HEADER);

-- -- OFDB --
-- \! echo '[OFDB]';
-- \copy data.food_des (food_id, fdgrp_id, data_src_id, long_desc, gtin_UPC, manufacturer, ingredients) FROM ../data/ofdb/FOOD_DES.csv WITH (FORMAT csv, HEADER);
-- \copy data.nut_data FROM ../data/ofdb/NUT_DATA.csv WITH (FORMAT csv, HEADER);



-- -- Set SEQUENCE indexes --
-- \! echo '[SEQUENCE] --> 2 billion';
-- ALTER SEQUENCE data.serving_id_msre_id_seq RESTART WITH 2000000000;
-- ALTER SEQUENCE data.food_des_food_id_seq RESTART WITH 2000000000;



-- Set index or tsvector --
-- \! echo '[INDEXING]';
-- ALTER TABLE data.food_des ADD TextSearch_Desc tsvector NULL;
-- UPDATE data.food_des set TextSearch_Desc = to_tsvector(long_desc);
