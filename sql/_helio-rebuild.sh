#!/bin/bash -e

DB=nutra_dev
SCHEMA=nt

source .env

cd "$(dirname "$0")"


# Create tables
psql -c "\i tables.sql" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$DB

# Import data
bash _helio-import.sh
