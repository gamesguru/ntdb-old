#!/bin/bash -e

cd "$(dirname "$0")"

DB=nutra

mkdir -p $DB
cd $DB

# Generate docs, convert DOT --> EPS
postgresql_autodoc -d $DB
dot -Tps $DB.dot -o $DB.eps

# Convert to SVG and move up
convert -flatten $DB.eps $DB.svg
mv $DB.svg ..
