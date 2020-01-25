#!/bin/bash
# A script to start the PostgreSQL server locally
# Set (in `.env` file) env vars:   PSQL_LOCAL_DB_DIR, PSQL_DB_NAME, PSQL_SCHEMA_NAME

# Read in env vars
source .env

# Init db (not required every time)
sudo chown -R $LOGNAME:$LOGNAME /var/run/postgresql
pg_ctl initdb -D $PSQL_LOCAL_DB_DIR -l $PSQL_LOCAL_DB_DIR/postgreslogfile || true
pg_ctl -D $PSQL_LOCAL_DB_DIR -l $PSQL_LOCAL_DB_DIR/postgreslogfile start || true

# Create db, set our search_path, other things
psql -c "CREATE DATABASE $PSQL_DB_NAME;" postgresql://$LOGNAME@localhost:5432/postgres || true
psql -c "\encoding UTF8" postgresql://$LOGNAME@localhost:5432/$PSQL_DB_NAME || true
psql -c "UPDATE pg_database SET encoding=pg_char_to_encoding('UTF8') WHERE datname='$PSQL_DB_NAME';" postgresql://$LOGNAME@localhost:5432/postgres || true
psql -c "ALTER ROLE $LOGNAME SET search_path TO $PSQL_SCHEMA_NAME;" postgresql://$LOGNAME@localhost:5432/$PSQL_DB_NAME || true

# Start the server
psql postgresql://$LOGNAME@localhost:5432/$PSQL_DB_NAME
