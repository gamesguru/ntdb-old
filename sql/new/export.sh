#!/bin/bash -e

DB=routesim
SCHEMA=cz

cd "$(dirname "$0")"
cd ../data

# Export each table
psql -Atc "SELECT tablename FROM pg_tables WHERE schemaname='$SCHEMA'" postgresql://$LOGNAME@localhost:5432/$DB |\
  while read TBL; do
    psql -c "COPY $SCHEMA.$TBL TO stdout WITH csv HEADER" postgresql://$LOGNAME@localhost:5432/$DB > $TBL.csv
  done
