#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun May 26 11:22:19 2019

@author: shane

nutra-db, a database for nutratracker clients
Copyright (C) 2020  Shane Jaroch <mathmuncher11@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

import os
import csv

from rda import rdas

if os.getcwd().endswith('/python'):
    os.chdir('..')

# USDA
print('Read in USDA')
raw_usda_nutdata = []
raw_usda_fooddes = []
raw_usda_weight = []
raw_usda_nutrdef = []
raw_usda_fdgrp = []

raw_usda_nutdata = list(csv.reader(
    open('tmp/usda/NUT_DATA.csv')
))
raw_usda_fooddes = list(csv.reader(
    open('tmp/usda/FOOD_DES.csv')
))
raw_usda_weight = list(csv.reader(
    open('tmp/usda/WEIGHT.csv')
))
raw_usda_nutrdef = list(csv.reader(
    open('tmp/usda/NUTR_DEF.csv')
))
raw_usda_fdgrp = list(csv.reader(
    open('tmp/usda/FD_GROUP.csv')
))


# BFDB
print('Read in BFDB')
raw_bfdb_nutdata = []
raw_bfdb_fooddes = []
raw_bfdb_servsize = []

raw_bfdb_nutdata = list(csv.reader(
    open('tmp/bfdb/Nutrient.csv')
))
raw_bfdb_fooddes = list(csv.reader(
    open('tmp/bfdb/Products.csv')
))
raw_bfdb_servsize = list(csv.reader(
    open('tmp/bfdb/Serving_Size.csv')
))


# CNF
print('Read in CNF')
raw_cnf_nutdata = []
raw_cnf_fooddes = []
raw_cnf_convfact = []
raw_cnf_measname = []
raw_cnf_nutrname = []
raw_cnf_fdgrp = []

raw_cnf_nutdata = list(csv.reader(
    open('tmp/cnf/NUTRIENT AMOUNT.csv')
))
raw_cnf_fooddes = list(csv.reader(
    open('tmp/cnf/FOOD NAME.csv', encoding='cp1252')
))
raw_cnf_convfact = list(csv.reader(
    open('tmp/cnf/CONVERSION FACTOR.csv')
))
raw_cnf_measname = list(csv.reader(
    open('tmp/cnf/MEASURE NAME.csv', encoding='cp1252')
))
raw_cnf_nutrname = list(csv.reader(
    open('tmp/cnf/NUTRIENT NAME.csv', encoding='cp1252')
))
raw_cnf_fdgrp = list(csv.reader(
    open('tmp/cnf/FOOD GROUP.csv', encoding='cp1252')
))


# Process nutr_def table
with open('adjust.csv', 'w+') as f:
    wtr = csv.writer(f)
    for r in raw_cnf_nutrname:
        wtr.writerow(r)
