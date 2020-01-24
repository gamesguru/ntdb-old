#!/bin/bash

cd "$(dirname "$0")"
cd tmp

#
# Branded foods DB
cd bfdb
( csvsql --snifflimit 100 --dialect postgresql Nutrient.csv;  csvsql --snifflimit 100 --dialect postgresql Products.csv;  csvsql --snifflimit 100 --dialect postgresql Serving_Size.csv; ) > ../bfdb.sql

#
# Canadian nutrient files
cd ../cnf
( csvsql --snifflimit 100 --dialect postgresql 'NUTRIENT AMOUNT.csv';  csvsql --snifflimit 100 --dialect postgresql -e iso8859 'FOOD NAME.csv';  csvsql --snifflimit 100 --dialect postgresql 'CONVERSION FACTOR.csv';  csvsql --snifflimit 100 --dialect postgresql -e iso8859 'MEASURE NAME.csv';  csvsql --snifflimit 100 --dialect postgresql -e iso8859 'NUTRIENT NAME.csv';  csvsql --snifflimit 100 --dialect postgresql -e iso8859 'FOOD GROUP.csv'; ) > ../cnf.sql

#
# Open foods DB
cd ../ofdb
head -1000 en.openfoodfacts.org.products.csv >> en.openfoodfacts.org.products-trunc.csv
csvsql --snifflimit 100 --dialect postgresql en.openfoodfacts.org.products-trunc.csv > ../ofdb.sql

#
# USDA standard references
cd ../usda
( csvsql --snifflimit 100 --dialect postgresql FD_GROUP.csv;  csvsql --snifflimit 100 --dialect postgresql FOOD_DES.csv;  csvsql --snifflimit 100 --dialect postgresql NUT_DATA.csv;  csvsql --snifflimit 100 --dialect postgresql NUTR_DEF.csv;  csvsql --snifflimit 100 --dialect postgresql WEIGHT.csv; ) > ../usda.sql
