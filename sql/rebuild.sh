#!/bin/bash -e

DB=nutra
SCHEMA=nt

cd "$(dirname "$0")"


# Create tables
psql -c "\i tables.sql" postgresql://$LOGNAME@localhost:5432/$DB

# Import data
bash import.sh
