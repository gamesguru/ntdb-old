#!/bin/bash -e

DB=nutra_dev
SCHEMA=nt

cd "$(dirname "$0")"
source .env

# Create tables
psql -c "\i tables.sql" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$DB

# Import data
bash _helio-import.sh

# Set tsvector
psql -c "ALTER TABLE food_des ADD TextSearch_Desc tsvector NULL" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$DB
psql -c "UPDATE food_des set TextSearch_Desc = to_tsvector(long_desc)" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$DB

# Stored Procedures
psql -c "\i functions.sql" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$DB
