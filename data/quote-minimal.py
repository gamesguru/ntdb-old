import csv


files = [
    "csv/usda/FD_GROUP.csv",
    "csv/usda/FOOD_DES.csv",
    "csv/usda/NUT_DATA.csv",
    "csv/usda/WEIGHT.csv",
]

for file in files:
    print(file)

    rows = []
    with open(file) as f:

        # Read in
        reader = csv.reader(f)
        for row in reader:
            rows.append(row)

    # Python automatically quotes minimal
    with open(file, "w+") as f:

        # Write out
        writer = csv.writer(f)
        writer.writerows(rows)
