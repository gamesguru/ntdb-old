import csv
import os
import sys

# change to script's dir
os.chdir(os.path.dirname(__file__))


files = [
    "csv/usda/FD_GROUP.csv",
    "csv/usda/FOOD_DES.csv",
    "csv/usda/NUT_DATA.csv",
    "csv/usda/NUTR_DEF.csv",
    "csv/usda/WEIGHT.csv",
]


def main(args):
    """ Processes the USDA data to get ready for ntdb """

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
        process(fname, rows)


def process(fname, rows):
    """ Processes files on a case-by-base basis """

    # Get "base name" and handle each separately
    bname = fname.split("/")[-1]
    if bname == "FOOD_DES.csv":
        pass

    # Write out new file
    with open(fname, "w+") as file:
        writer = csv.writer(file)
        writer.writerows(rows)


#
# Make script executable
if __name__ == "__main__":
    main(sys.argv[1:])
