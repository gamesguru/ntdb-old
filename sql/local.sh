#!/bin/bash

DB=nutra
SCHEMA=nt

cd "$(dirname "$0")"
source .env

# Init db (not required every time)
sudo chown -R $LOGNAME:$LOGNAME /var/run/postgresql
pg_ctl initdb -D $PSQL_LOCAL_DB_DIR -l $PSQL_LOCAL_DB_DIR/postgreslogfile || true
pg_ctl -D $PSQL_LOCAL_DB_DIR -l $PSQL_LOCAL_DB_DIR/postgreslogfile start || true

# Create db, set our search_path, other things
psql -c "CREATE DATABASE $DB;" postgresql://$LOGNAME@localhost:5432/postgres || true
psql -c "\encoding UTF8" postgresql://$LOGNAME@localhost:5432/$DB || true
psql -c "UPDATE pg_database SET encoding=pg_char_to_encoding('UTF8') WHERE datname='$DB';" postgresql://$LOGNAME@localhost:5432/postgres || true
psql -c "ALTER ROLE $LOGNAME SET search_path TO $SCHEMA;" postgresql://$LOGNAME@localhost:5432/$DB || true

# Start the server
psql postgresql://$LOGNAME@localhost:5432/$DB
