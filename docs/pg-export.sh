#!/bin/bash -e

export db=nutra

cd docs
mkdir -p $db
cd $db

# Generate docs, convert DOT --> EPS
postgresql_autodoc -d $db
dot -Tps $db.dot -o $db.eps

# Convert to SVG and move up
convert -flatten $db.eps $db.svg
mv $db.svg ..

