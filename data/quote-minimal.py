import csv

rows = []

with open('tmp/bfdb/Serving_Size.csv') as f:

    # Read in
    reader = csv.reader(f)
    for row in reader:
        rows.append(row)

# Python automatically quotes minimal
with open('tmp/bfdb/Serving_Size.csv', 'w+') as f:

    # Write out
    writer = csv.writer(f)
    writer.writerows(rows)
