#!/bin/bash -e

source .env
DB=routesim_dev
SCHEMA=cz

cd "$(dirname "$0")"


# Create tables
psql -c "\i tables.sql" postgresql://routesim_admin:$PSQL_PASSWORD@$PSQL_HOST:5432/$DB

# Import data
bash _helio-import.sh
