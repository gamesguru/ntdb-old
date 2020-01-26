# nutra-db, a database for nutratracker clients
# Copyright (C) 2020  Nutra, LLC. [Shane & Kyle] <nutratracker@gmail.com>

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

import csv
import os
import sys

# change to script's dir
os.chdir(os.path.dirname(os.path.abspath(__file__)))
os.makedirs("csv/nt", 0o755, True)


#
# Input --> Output (dict)
output_files = {
    "csv/usda/FD_GROUP.csv": "csv/nt/fdgrp.csv",
    # "csv/usda/FOOD_DES.csv": "csv/nt/food_des.csv",
    # "csv/usda/NUT_DATA.csv": "csv/nt/nut_data.csv",
    "csv/usda/NUTR_DEF.csv": "csv/nt/nutr_def.csv",
    # "csv/usda/WEIGHT.csv": None,
}

special_interests_dirs = [
    "csv/usda/isoflav",
    "csv/usda/proanth",
    "csv/usda/flav",
]

#
# Recommanded daily allowances
rdas = {"Nutr_no": ("rda", "tagname")}

with open("csv/RDA.csv") as file:
    reader = csv.reader(file)
    for row in reader:
        rdas[row[0]] = row[1], row[3]


def main(args):
    """ Processes the USDA data to get ready for ntdb """

    print("==> Process CSV")

    #
    # Process main USDA csv files
    for fname in output_files:
        print(fname)

        # Open the CSV file
        rows = []
        with open(fname) as file:

            # Read in
            reader = csv.reader(file)
            for row in reader:
                rows.append(row)

        # Process and write out
        if fname == "csv/usda/WEIGHT.csv":
            process_weight(rows, fname)
        else:
            process(rows, fname)

    #
    # Process Special Interests (flav, isoflav, proanth)
    process_special_interests_dirs()


def process(rows, fname):
    """ Processes files on a case-by-base basis """

    # Process the rows
    rows = [process_row(r, fname) for r in rows]

    # Write out new file
    with open(output_files[fname], "w+") as file:
        writer = csv.writer(file)
        writer.writerows(rows)


def process_row(row, fname):
    """ Processes a single row """

    # Get "base name" and handle each separately
    bname = fname.split("/")[-1]

    # Process row based on FILE_TYPE
    if bname == "NUTR_DEF.csv":
        rda, tagname = rdas[row[0]]
        row = row[:4]
        row[2] = tagname
        row.insert(1, rda)
    elif bname == "FOOD_DES.csv":
        row = row[:10]
        del row[6]
    elif bname == "NUT_DATA.csv":
        row = row[:3]
    elif bname == "WEIGHT.csv":
        pass

    return row


def process_weight(rows, fname):

    # Unique qualifiers
    msre_ids = {}
    servings_set = set()

    # CSV rows
    serving_id = [["id", "msre_desc"]]
    servings = [["food_id", "msre_id", "grams"]]

    id = 1
    for i, row in enumerate(rows):
        if i == 0:
            continue

        # Process row
        food_id = int(row[0])
        amount = float(row[2])
        if amount <= 0:
            continue
        msre_desc = row[3]
        grams = float(row[4])
        grams /= amount

        # Get key if used previously
        if not msre_desc in msre_ids:
            serving_id.append([id, msre_desc])
            msre_ids[msre_desc] = id
            id += 1
        msre_id = msre_ids[msre_desc]

        # Handles some weird duplicates, e.g.
        # ERROR:  duplicate key value violates unique constraint "servings_pkey"
        # DETAIL:  Key (food_id, msre_id)=(1036, 3) already exists.
        # CONTEXT:  COPY servings, line 128
        prim_key = (food_id, msre_id)
        if not prim_key in servings_set:
            servings.append([food_id, msre_id, grams])
            servings_set.add(prim_key)

    # Write serving_id and servings tables
    with open("csv/nt/serving_id.csv", "w+") as file:
        writer = csv.writer(file)
        writer.writerows(serving_id)
    with open("csv/nt/servings.csv", "w+") as file:
        writer = csv.writer(file)
        writer.writerows(servings)


def process_special_interests_dirs():
    """ Processes flav, isoflav, and proanth "special interests" databases """

    #
    # Read in existing data
    nut_data_rows = []
    nutr_def_rows = []
    with open("csv/nt/nut_data.csv") as file:
        reader = csv.reader(file)
        for row in reader:
            nut_data_rows.append(row)

    with open("csv/nt/nutr_def.csv") as file:
        reader = csv.reader(file)
        for row in reader:
            nutr_def_rows.append(row)

    #
    # Add to it
    for dir in special_interests_dirs:

        # nut_data_si_rows = []
        # nutr_def_si_rows = []

        with open(f"{dir}/NUTR_DEF.csv") as file:
            reader = csv.reader(file)
            for row in reader:
                rda, tagname = rdas[row[0]]
                row = row[:4]
                row[2] = tagname
                row.insert(1, rda)

        # with open(f"{dir}/NUT_DATA.csv") as file:
        #     reader = csv.reader(file)
        #     for row in reader:
        #         nutr_def_si_rows.append(row)

        # # Get "base name" and handle each separately
        # bname = fname.split("/")[-1]
        # print(bname)
        print(dir)


#
# Make script executable
if __name__ == "__main__":
    main(sys.argv[1:])
