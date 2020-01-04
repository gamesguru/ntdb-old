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

import sys
import csv
import operator

# OFDB (flat file)
print('Read in OFDB')
raw_ofdb_data = []
with open('tmp/ofdb/en.openfoodfacts.org.products.csv', 'r') as f:
    raw_ofdb_data = list(csv.reader(f))
