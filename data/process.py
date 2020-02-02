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


# --------------------
# io dict
# --------------------
output_files = {
    "csv/usda/FD_GROUP.csv": "csv/nt/fdgrp.csv",
    "csv/usda/WEIGHT.csv": None,
}

special_interests_dirs = [
    "csv/usda/isoflav",
    "csv/usda/proanth",
    "csv/usda/flav",
]

# --------------------
# RDAs
# --------------------
rdas = {"NUTR_NO": ("rda", "tagname")}
with open("csv/RDA.csv") as file:
    reader = csv.reader(file)
    for row in reader:
        rdas[row[0].upper()] = row[1], row[3]


"""
# --------------------
# main method
# --------------------
"""


def main(args):
    """ Processes the USDA data to get ready for ntdb """

    # -----------------
    # Process USDA csv
    # -----------------
    print("==> Process CSV")
    process_nutr_def()
    process_nut_data()
    process_food_des()

    for fname in output_files:
        print(fname)
        # Open the CSV file
        with open(fname) as file:
            reader = csv.reader(file)
            rows = list(reader)
        #
        # Process and write out
        if fname == "csv/usda/WEIGHT.csv":
            process_weight(rows, fname)
        else:
            process(rows, fname)


# ----------------------
# Handle general file
# ----------------------
def process(rows, fname):
    """ Processes FD_GRP only :O """

    with open(output_files[fname], "w+") as file:
        writer = csv.writer(file, lineterminator="\n")
        writer.writerows(rows)


# -----------------
# Nutrient defs
# -----------------
def process_nutr_def():
    """ Process nutr_def """

    def process_main(rows):
        result = []
        for row in rows:
            rda, tagname = rdas[row[0].upper()]
            row = row[:4]
            row[2] = tagname
            row.insert(1, rda)
            row.append(False)  # is_anti
            row.append(None)  # user_id
            row.append(True)  # is_shared
            # Add to list
            result.append(row.copy())
        return result

    def process_si(rows):
        result = []
        # Header indexes
        h = rows[0]
        unit_d = ["UNITS", "UNIT"]
        nutr_d = ["NUTRDESC", "NUTRIENT NAME"]
        unit_i = h.index(next(x for x in h if x.upper() in unit_d))
        desc_i = h.index(next(x for x in h if x.upper() in nutr_d))

        # Process rows
        for _row in rows[1:]:
            rda, tagname = rdas[_row[0].upper()]
            nutr_id = _row[0]
            # Set new row
            row = [None] * 8
            row[0] = nutr_id
            row[1] = rda
            row[2] = _row[unit_i]
            row[3] = tagname
            row[4] = _row[desc_i]
            row[5] = False  # is_anti
            row[6] = None  # user_id
            row[7] = True  # is_shared
            # Add to list
            result.append(row)
        return result

    #
    # Prepare the rows
    result = []

    # Main USDA files
    main_nutr = "csv/usda/NUTR_DEF.csv"
    print(main_nutr)
    with open(main_nutr) as file:
        reader = csv.reader(file)
        rows = list(reader)
        rows = process_main(rows)
        # Add to final solution
        result.extend(rows)

    # Special interests DB
    for dir in special_interests_dirs:
        sub_nutr = f"{dir}/NUTR_DEF.csv"
        print(sub_nutr)
        with open(sub_nutr) as file:
            reader = csv.reader(file)
            rows = list(reader)
            rows = process_si(rows)
            # Add to final solution
            result.extend(rows)

    #
    # Write out result
    with open(f"csv/nt/nutr_def.csv", "w+") as file:
        writer = csv.writer(file, lineterminator="\n")
        writer.writerows(result)


# -----------------
# Nutrient data
# -----------------
def process_nut_data():
    #
    # Prepare the rows
    result = []

    # Main USDA files
    main_nutr = "csv/usda/NUT_DATA.csv"
    print(main_nutr)
    with open(main_nutr) as file:
        reader = csv.reader(file)
        rows = list(reader)
        # Add to final solution
        for row in rows:
            result.append(row[:3])

    # Special interests DB
    for dir in special_interests_dirs:
        sub_nutr = f"{dir}/NUT_DATA.csv"
        print(sub_nutr)
        with open(sub_nutr) as file:
            reader = csv.reader(file)
            rows = list(reader)
            # Add to final solution
            for row in rows[1:]:
                result.append(row[:3])

    #
    # Write out result
    with open(f"csv/nt/nut_data.csv", "w+") as file:
        writer = csv.writer(file, lineterminator="\n")
        writer.writerows(result)


# -----------------
# Food description
# -----------------
def process_food_des():
    #
    # Prepare the rows
    result = []
    food_ids = set()

    # Main USDA files
    main_nutr = "csv/usda/FOOD_DES.csv"
    print(main_nutr)
    with open(main_nutr) as file:
        reader = csv.reader(file)
        rows = list(reader)
        # Add to final solution
        for i, _row in enumerate(rows):
            if i > 0:
                food_ids.add(int(_row[0]))
            row = _row[:10]
            del row[6]
            row.insert(2, 1)  # Data src
            row.append(None)  # user_id
            row.append(True)  # is_shared
            result.append(row)
            # result.append(row[:3])

    # Special interests DB
    for dir in special_interests_dirs:
        sub_nutr = f"{dir}/FOOD_DES.csv"
        print(sub_nutr)
        with open(sub_nutr) as file:
            reader = csv.reader(file)
            rows = list(reader)
            # Add to final solution
            for _row in rows[1:]:
                food_id = int(_row[0])

                # Don't add dupes
                if not food_id in food_ids:
                    print(f"new food: {food_id} {_row[2]}")
                    food_ids.add(food_id)
                    # Set new row
                    row = [None] * 12
                    row[0] = food_id
                    row[1] = _row[1]  # Food group
                    row[2] = 2        # Data src
                    row[3] = _row[2]  # Long Desc
                    if len(_row) > 3:
                        row[5] = _row[3]  # Sci name
                    row[11] = True  # is_shared
                    result.append(row)

    #
    # Write out result
    with open(f"csv/nt/food_des.csv", "w+") as file:
        writer = csv.writer(file, lineterminator="\n")
        writer.writerows(result)


# -----------------
# Weight
# -----------------
def process_weight(rows, fname):

    # Unique qualifiers
    msre_ids = {}
    servings_set = set()

    # CSV rows
    serving_id = [["id", "msre_desc"]]
    servings = [["food_id", "msre_id", "grams"]]

    #
    # Main logic
    id = 1
    for row in rows[1:]:
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
        prim_key = (food_id, msre_id)
        if not prim_key in servings_set:
            servings.append([food_id, msre_id, grams])
            servings_set.add(prim_key)

    #
    # Write serving_id and servings tables
    with open("csv/nt/serving_id.csv", "w+") as file:
        writer = csv.writer(file, lineterminator="\n")
        writer.writerows(serving_id)
    with open("csv/nt/servings.csv", "w+") as file:
        writer = csv.writer(file, lineterminator="\n")
        writer.writerows(servings)


#
# Make script executable
if __name__ == "__main__":
    main(sys.argv[1:])
