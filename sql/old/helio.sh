#!/bin/bash

DB=nutra_dev
SCHEMA=nt

cd "$(dirname "$0")"
source .env

# SET search_path
psql -c "ALTER ROLE $PSQL_HELIO_USER SET search_path TO $SCHEMA" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/nutra_dev

# Connect to DB
psql postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/nutra_dev
