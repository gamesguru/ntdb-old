#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun May 26 11:22:19 2019

@author: shane

Copyright (C) Nutra, LLC - All Rights Reserved
Unauthorized copying of this file, via any medium is strictly prohibited
Proprietary and confidential
Written by Shane Jaroch <mathmuncher11@gmail.com>, May 2019
"""

import sys
import csv
import operator


# USDA
print('Read in USDA')
raw_usda_nutdata = []
raw_usda_fooddes = []
raw_usda_weight = []
raw_usda_nutrdef = []
raw_usda_fdgrp = []
with open('tmp/usda/NUT_DATA.csv', 'r') as f:
    raw_usda_nutdata = list(csv.reader(f))
with open('tmp/usda/FOOD_DES.csv', 'r') as f:
    raw_usda_fooddes = list(csv.reader(f))
with open('tmp/usda/WEIGHT.csv', 'r') as f:
    raw_usda_weight = list(csv.reader(f))
with open('tmp/usda/NUTR_DEF.csv', 'r') as f:
    raw_usda_nutrdef = list(csv.reader(f))
with open('tmp/usda/FD_GROUP.csv', 'r') as f:
    raw_usda_fdgrp = list(csv.reader(f))


# BFDB
print('Read in BFDB')
raw_bfdb_nutdata = []
raw_bfdb_fooddes = []
raw_bfdb_servsize = []
with open('tmp/bfdb/Nutrient.csv', 'r') as f:
    raw_bfdb_nutdata = list(csv.reader(f))
with open('tmp/bfdb/Products.csv', 'r') as f:
    raw_bfdb_fooddes = list(csv.reader(f))
with open('tmp/bfdb/Serving_Size.csv', 'r') as f:
    raw_bfdb_servsize = list(csv.reader(f))


# CNF
print('Read in CNF')
raw_cnf_nutdata = []
raw_cnf_fooddes = []
raw_cnf_convfact = []
raw_cnf_measname = []
raw_cnf_nutrname = []
raw_cnf_fdgrp = []
with open('tmp/cnf/NUTRIENT AMOUNT.csv', 'r') as f:
    raw_cnf_nutdata = list(csv.reader(f))
with open('tmp/cnf/FOOD NAME.csv', 'r') as f:
    raw_cnf_fooddes = list(csv.reader(f))
with open('tmp/cnf/CONVERSION FACTOR.csv', 'r') as f:
    raw_cnf_convfact = list(csv.reader(f))
with open('tmp/cnf/MEASURE NAME.csv', 'r') as f:
    raw_cnf_measname = list(csv.reader(f))
with open('tmp/cnf/NUTRIENT NAME.csv', 'r') as f:
    raw_cnf_nutrname = list(csv.reader(f))
with open('tmp/cnf/FOOD GROUP.csv', 'r') as f:
    raw_cnf_fdgrp = list(csv.reader(f))


# Process nutr_def table
rdas = [[203, 60], [204, 90], [205, 250], [208, 2050], [269, 80], [291, 30], [301, 1300], [302, 550], [303, 18], [304, 420], [305, 1250], [306, 4700], [307, 1500], [309, 11], [310, 35], [312, 0.9], [314, 150], [315, 2.3], [316, 45], [317, 55], [318, 5000], [320, 900], [324, 400], [328, 20], [337, 3000], [338, 7000], [394, 15], [401, 90], [404, 1.2], [405, 1.3], [406, 16], [410, 5], [415, 1.7], [416, 30], [417, 400], [418, 2.4], [421, 550], [430, 120], [501, 0.3], [502, 1], [503, 1.4], [504, 2.7], [505, 2.1], [506, 0.8], [508, 1.2], [509, 1.4], [510, 1.8], [511, 1], [512, 0.8], [513, 1], [514, 1], [515, 2], [516, 0.8], [517, 0.6], [518, 1.6], [526, 0.3], [529, 0.4], [601, 200], [605, 0], [606, 30], [621, 0.2], [629, 0.1], [645, 35], [646, 25], [710, 30], [711, 15], [712, ], [713, 45], [731, 20], [734, 10], [735, 5], [736, 5], [737, 2], [738, 1], [749, 40], [750, 40], [751, 40], [752, 40], [753, 60], [759, 80], [762, 60], [770, 30], [773, 20], [785, 5], [786, 5], [788, 2], [789, 20]]
