#!/bin/bash -e

DB=routesim

cd "$(dirname "$0")"

# Make folder
mkdir -p docs/$DB
cd docs/$DB

# Generate docs, convert DOT --> EPS
postgresql_autodoc -d $DB
dot -Tps $DB.dot -o $DB.eps

# Convert to SVG and move up
convert -flatten $DB.eps $DB.svg
convert -flatten $DB.eps $DB.png
mv $DB.eps ..
mv $DB.svg ..
mv $DB.png ../../..
