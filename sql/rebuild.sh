#!/bin/bash -e

cd "$(dirname "$0")"
source .env


# Create tables
psql -c "\i tables.sql" postgresql://$PSQL_USER:$PSQL_PASSWORD@$PSQL_HOST:5432/$PSQL_DB_NAME

# Import data
bash import.sh

# Set tsvector
psql -c "ALTER TABLE $PSQL_SCHEMA_NAME.food_des ADD TextSearch_Desc tsvector NULL" postgresql://$PSQL_USER:$PSQL_PASSWORD@$PSQL_HOST:5432/$PSQL_DB_NAME
psql -c "UPDATE $PSQL_SCHEMA_NAME.food_des set TextSearch_Desc = to_tsvector(long_desc)" postgresql://$PSQL_USER:$PSQL_PASSWORD@$PSQL_HOST:5432/$PSQL_DB_NAME

# Stored Procedures
psql -c "\i functions.sql" postgresql://$PSQL_USER:$PSQL_PASSWORD@$PSQL_HOST:5432/$PSQL_DB_NAME
