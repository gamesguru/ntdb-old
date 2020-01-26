#!/bin/bash

cd "$(dirname "$0")"
source .env

# Connect to DB
psql postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$PSQL_HELIO_DB_NAME
