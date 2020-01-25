#!/bin/bash
# A script to connect to remote HelioHost postgreSQL server
# Set env vars:   PSQL_PASSWORD, PSQL_HOST

# Read in env vars
source .env

# TODO - fix this

# Connect to DB
psql postgresql://nutra:$PSQL_PASSWORD@$PSQL_HOST:5432/nutra
