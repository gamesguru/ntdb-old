#!/bin/bash
# A script to connect to remote HelioHost postgreSQL server
# Set env vars:   PSQL_HELIO_HOST, PSQL_HELIO_USERNAME, PSQL_HELIO_PASSWORD, PSQL_HELIO_DB_NAME

# Read in env vars
source .env

# TODO - fix this

# Connect to DB
psql postgresql://$PSQL_HELIO_USERNAME:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$PSQL_HELIO_DB_NAME
