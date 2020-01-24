import csv


files = ['tmp/bfdb/Serving_Size.csv', 'tmp/usda/FD_GROUP.csv', 'tmp/usda/FOOD_DES.csv', 'tmp/usda/NUT_DATA.csv', 'tmp/usda/WEIGHT.csv']

for file in files:
    print(file)

    rows = []
    with open(file) as f:

        # Read in
        reader = csv.reader(f)
        for row in reader:
            rows.append(row)

    # Python automatically quotes minimal
    with open(file, 'w+') as f:

        # Write out
        writer = csv.writer(f)
        writer.writerows(rows)
