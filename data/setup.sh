#!/bin/bash
#
# Copyright (C) Nutra, LLC - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Shane Jaroch <mathmuncher11@gmail.com>, May 2019
#


mkdir tmp
cd tmp

# Download and unzip
curl -O "https://www.ars.usda.gov/ARSUserFiles/80400525/Data/SR-Legacy/SR-Leg_DB.zip"
curl -O "https://www.ars.usda.gov/ARSUserFiles/80400525/Data/BFPDB/BFPD_db_07132018.zip"
curl -O "https://www.canada.ca/content/dam/hc-sc/migration/hc-sc/fn-an/alt_formats/zip/nutrition/fiche-nutri-data/cnf-fcen-csv.zip"
unzip SR-Leg_DB.zip SR_Legacy.accdb
rm SR-Leg_DB.zip
unzip BFPD_db_07132018.zip BFPD_07132018.accdb
rm BFPD_db_07132018.zip
unzip cnf-fcen-csv.zip -d cnf/
rm cnf-fcen-csv.zip
mkdir ofdb
curl -o ofdb/en.openfoodfacts.org.products.csv "https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv"


# Run access2csv
git clone git@github.com:AccelerationNet/access2csv.git
cd access2csv
mvn clean install
./access2csv --input ../SR_Legacy.accdb --output ../usda --with-header
./access2csv --input ../BFPD_07132018.accdb --output ../bfdb --with-header
cd ..


# Clean up
rm SR-Leg_DB.zip
rm BFPD_db_07132018.zip
rm cnf-fcen-csv.zip

rm -rf access2csv
rm BFPD_07132018.accdb
rm SR_Legacy.accdb

rm cnf/*.pdf
rm "cnf/REFUSE NAME.csv"
rm "cnf/YIELD NAME.csv"
rm "cnf/REFUSE AMOUNT.csv"
rm "cnf/YIELD AMOUNT.csv"
rm "cnf/FOOD SOURCE.csv"
rm "cnf/NUTRIENT SOURCE.csv"
rm bfdb/Derivation_Code_Description.csv
rm usda/DATSRCLN.csv
rm usda/LANGUAL.csv
rm usda/DATA_SRC.csv
rm usda/FOOTNOTE.csv
rm usda/LANGDESC.csv
rm usda/DERIV_CD.csv
rm usda/SRC_CD.csv

# Start python script
# ./process.py
