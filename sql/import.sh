#!/bin/bash

cd "$(dirname "$0")"
source .env
cd ../data/csv/nt

# ------------------------------
# Import primary tables
# ------------------------------
declare -a ptables=("users" "nutr_def")
for table in "${ptables[@]}"
do
  echo $table
  psql -c "\copy $PSQL_SCHEMA_NAME.$table FROM '${table}.csv' WITH csv HEADER" postgresql://$PSQL_USER:$PSQL_PASSWORD@$PSQL_HOST:5432/$PSQL_DB_NAME
done


# ------------------------------
# Import remaining tables
# ------------------------------
for filename in *.csv; do
  # https://stackoverflow.com/questions/12590490/splitting-filename-delimited-by-period
  table="${filename%%.*}"

  # Skip capital letters, they are original DB files
  if [[ $table =~ [a-z] ]]; then
    # Skip covered tables
    # https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value
    if [[ ! " ${ptables[@]} " =~ " ${table} " ]]; then
      echo $table
      cat "$filename" | psql -c "\copy $PSQL_SCHEMA_NAME.$table FROM $table.csv WITH csv HEADER" postgresql://$PSQL_USER:$PSQL_PASSWORD@$PSQL_HOST:5432/$PSQL_DB_NAME
    fi
  fi
done


# ------------------------------
# Set serial maxes
# ------------------------------
# TODO: add remaining indexed "itables"
declare -a itables=("users")
for table in "${itables[@]}"
do
  echo $table
  psql -c "SELECT pg_catalog.setval(pg_get_serial_sequence('$table', 'id'), (SELECT MAX(id) FROM $table))" postgresql://$PSQL_USER:$PSQL_PASSWORD@$PSQL_HOST:5432/$PSQL_DB_NAME
done
