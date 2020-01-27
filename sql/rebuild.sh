#!/bin/bash -e

DB=nutra
SCHEMA=nt

cd "$(dirname "$0")"


# Create tables
psql -c "\i tables.sql" postgresql://$LOGNAME@localhost:5432/$DB

# Import data
bash import.sh

# Set tsvector
psql -c "ALTER TABLE food_des ADD TextSearch_Desc tsvector NULL" postgresql://$LOGNAME@localhost:5432/$DB
psql -c "UPDATE food_des set TextSearch_Desc = to_tsvector(long_desc)" postgresql://$LOGNAME@localhost:5432/$DB

# Stored Procedures
psql -c "\i functions.sql" postgresql://$LOGNAME@localhost:5432/$DB
