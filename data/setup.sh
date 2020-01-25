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
#

# cd to script's directory
cd "$(dirname "$0")"

# Create tmp dir
mkdir -p tmp
cd tmp

#
# Download and unzip
curl -O "https://www.ars.usda.gov/ARSUserFiles/80400525/Data/SR-Legacy/SR-Leg_DB.zip"
unzip SR-Leg_DB.zip SR_Legacy.accdb

#
# Run access2csv
git clone git@github.com:AccelerationNet/access2csv.git

cd access2csv
mvn clean install -Dmaven.test.skip=true
./access2csv --input ../SR_Legacy.accdb --output ../usda --with-header
cd ..

#
# Move to permanent home
mkdir -p ../csv
cd ../csv
rm -rf usda
mv ../tmp/usda .

#
# Clean up
rm -rf ../tmp
cd usda

rm DATSRCLN.csv
rm LANGUAL.csv
rm DATA_SRC.csv
rm FOOTNOTE.csv
rm LANGDESC.csv
rm DERIV_CD.csv
rm SRC_CD.csv

# Use standard table naming conventions
mv FD_GROUP.csv fdgrp.csv
mv FOOD_DES.csv food_des.csv
mv NUT_DATA.csv nut_data.csv
mv NUTR_DEF.csv nutr_def.csv
