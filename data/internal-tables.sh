#!/bin/bash

cd "$(dirname "$0")"
cd tmp

# Branded foods DB
cd bfdb
csvsql  --snifflimit 1000 --dialect postgresql Nutrient.csv > ../bfdb-Nutrient.sql
csvsql  --snifflimit 1000 --dialect postgresql Products.csv > ../bfdb-Products.sql
csvsql  --snifflimit 1000 --dialect postgresql Serving_Size.csv > ../bfdb-Serving_Size.sql

# Canadian nutrient files
cd ../cnf
csvsql  --snifflimit 1000 --dialect postgresql 'NUTRIENT AMOUNT.csv' > '../cnf-NUTRIENT AMOUNT.sql'
csvsql  --snifflimit 1000 --dialect postgresql 'FOOD NAME.csv' > '../cnf-FOOD NAME.sql'
csvsql  --snifflimit 1000 --dialect postgresql 'CONVERSION FACTOR.csv' > '../cnf-CONVERSION FACTOR.sql'
csvsql  --snifflimit 1000 --dialect postgresql 'MEASURE NAME.csv' > '../cnf-MEASURE NAME.sql'
csvsql  --snifflimit 1000 --dialect postgresql 'NUTRIENT NAME.csv' > '../cnf-NUTRIENT NAME.sql'
csvsql  --snifflimit 1000 --dialect postgresql 'FOOD GROUPS.csv' > '../cnf-FOOD GROUP.sql'

# Open foods DB
cd ../ofdb
head -10000 en.openfoodfacts.org.products.csv >> en.openfoodfacts.org.products-trunc.csv
csvsql  --snifflimit 1000 --dialect postgresql en.openfoodfacts.org.products-trunc.csv > ../ofdb.sql

# USDA standard references
cd ../usda
csvsql  --snifflimit 1000 --dialect postgresql FD_GROUP.csv > ../usda-FD_GROUP.sql
csvsql  --snifflimit 1000 --dialect postgresql FOOD_DES.csv > ../usda-FOOD_DES.sql
csvsql  --snifflimit 1000 --dialect postgresql NUT_DATA.csv > ../usda-NUT_DATA.sql
csvsql  --snifflimit 1000 --dialect postgresql NUTR_DEF.csv > ../usda-NUTR_DEF.sql
csvsql  --snifflimit 1000 --dialect postgresql WEIGHT.csv > ../usda-WEIGHT.sql
