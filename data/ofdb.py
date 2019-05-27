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

# OFDB (flat file)
print('Read in OFDB')
raw_ofdb_data = []
with open('tmp/ofdb/en.openfoodfacts.org.products.csv', 'r') as f:
    raw_ofdb_data = list(csv.reader(f))
