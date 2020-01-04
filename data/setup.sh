#!/bin/bash -e

# nutra-db, a database for nutratracker clients
# Copyright (C) 2020  Shane Jaroch <mathmuncher11@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.



# Create tmp dir
mkdir tmp
cd tmp



# Download and unzip
curl -O "https://www.ars.usda.gov/ARSUserFiles/80400525/Data/SR-Legacy/SR-Leg_DB.zip"
curl -O "https://www.ars.usda.gov/ARSUserFiles/80400525/Data/BFPDB/BFPD_db_07132018.zip"
curl -O "https://www.canada.ca/content/dam/hc-sc/migration/hc-sc/fn-an/alt_formats/zip/nutrition/fiche-nutri-data/cnf-fcen-csv.zip"
unzip SR-Leg_DB.zip SR_Legacy.accdb
unzip BFPD_db_07132018.zip BFPD_07132018.accdb
unzip cnf-fcen-csv.zip -d cnf/

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
