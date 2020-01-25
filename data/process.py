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


files = [
    "csv/usda/FD_GROUP.csv",
    "csv/usda/FOOD_DES.csv",
    "csv/usda/NUT_DATA.csv",
    "csv/usda/NUTR_DEF.csv",
    "csv/usda/WEIGHT.csv",
]


def main(args):
    """ Processes the USDA data to get ready for ntdb """

    print("==> Process CSV")

    for fname in files:
        print(fname)

        # Open the CSV file
        rows = []
        with open(fname) as file:

            # Read in
            reader = csv.reader(file)
            for row in reader:
                rows.append(row)

        # Process and write out
        process(rows, fname)


def process(rows, fname):
    """ Processes files on a case-by-base basis """

    # Process the rows
    rows = [process_row(r, fname) for r in rows]

    # Write out new file
    with open(fname, "w+") as file:
        writer = csv.writer(file)
        writer.writerows(rows)


def process_row(row, fname):
    """ Processes a single row """

    # Get "base name" and handle each separately
    bname = fname.split("/")[-1]

    # Process row based on FILE_TYPE
    if bname == "FOOD_DES.csv":
        row = row[:10]
        del row[6]

    return row


#
# Make script executable
if __name__ == "__main__":
    main(sys.argv[1:])
