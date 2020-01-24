
\! echo '\nBEGIN: [export.sql]';



-- DATA_SRCs
\! echo '[DATA SRC IDs]';
\copy data.data_src TO './data/DATA_SRC.csv' WITH csv HEADER;



-- USDA
\! echo '[USDA]';
\copy data.fdgrp TO './data/FD_GROUP.csv' WITH csv HEADER;
\copy data.tag_id TO './data/TAGS.csv' WITH csv HEADER;

\copy data.nutr_def TO './data/NUTR_DEF.csv' WITH csv HEADER;

\copy data.food_des TO './data/usda/FOOD_DES.csv' WITH csv HEADER;

\copy data.nut_data TO './data/usda/NUT_DATA.csv' WITH csv HEADER;
\copy data.nut_data TO './data/usda/fields/ALA_5.csv' WITH csv HEADER;
\copy data.nut_data TO './data/usda/fields/EpaDha_6.csv' WITH csv HEADER;

\copy data.serving_id TO './data/SERVING_ID.csv' WITH csv HEADER;
\copy data.serving TO './data/usda/WEIGHT.csv' WITH csv HEADER;
