#!/bin/bash

cd "$(dirname "$0")"
cd csv

#
# USDA standard references
cd usda
( csvsql --snifflimit 100 --dialect postgresql FD_GROUP.csv;  csvsql --snifflimit 100 --dialect postgresql FOOD_DES.csv;  csvsql --snifflimit 100 --dialect postgresql NUT_DATA.csv;  csvsql --snifflimit 100 --dialect postgresql NUTR_DEF.csv;  csvsql --snifflimit 100 --dialect postgresql WEIGHT.csv; ) > ../usda.sql
