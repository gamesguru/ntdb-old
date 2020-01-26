#!/bin/bash -e

DB=nutra
SCHEMA=nt

cd "$(dirname "$0")"
cd ../data/csv/nt

# Export each table
psql -Atc "select tablename from pg_tables where schemaname='$SCHEMA'" postgresql://$LOGNAME@localhost:5432/$DB |\
  while read TBL; do
    echo $TBL
    psql -c "COPY $SCHEMA.$TBL TO stdout WITH csv HEADER" postgresql://$LOGNAME@localhost:5432/$DB > $TBL.csv
  done
