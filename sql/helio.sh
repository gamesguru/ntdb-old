#!/bin/bash
# A script to connect to remote HelioHost postgreSQL server
# Set env vars:   PSQL_HOST, PSQL_USERNAME, PSQL_PASSWORD, PSQL_DB

# Read in env vars
source .env

# TODO - fix this

# Connect to DB
psql postgresql://$PSQL_USERNAME:$PSQL_PASSWORD@$PSQL_HOST:5432/$PSQL_DB
