#!/bin/bash

DB=nutra_dev
SCHEMA=nt


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
  psql -c "\copy $SCHEMA.$table FROM '${table}.csv' WITH csv HEADER" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$DB
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
      cat "$filename" | psql -c "\copy $SCHEMA.$table FROM $table.csv WITH csv HEADER" postgresql://$PSQL_HELIO_USER:$PSQL_HELIO_PASSWORD@$PSQL_HELIO_HOST:5432/$DB
    fi
  fi
done
