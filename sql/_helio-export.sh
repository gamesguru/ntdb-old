#!/bin/bash -e

DB=nutra_dev
SCHEMA=nt

source .env

cd "$(dirname "$0")"
cd ../data/csv/nt

# Export each table
psql -Atc "select tablename from pg_tables where schemaname='$SCHEMA'" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$DB |\
  while read TBL; do
    echo $TBL
    psql -c "COPY $SCHEMA.$TBL TO stdout WITH csv HEADER" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$DB > $TBL.csv
  done
