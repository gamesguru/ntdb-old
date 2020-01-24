#!/bin/bash -e

source .env
DB=routesim_dev
SCHEMA=cz

cd "$(dirname "$0")"
cd ../data

# Import primary tables
declare -a ptables=("tenants" "solvers" "simulators" "req_srcs" "scens")
for table in "${ptables[@]}"
do
  echo $table
  psql -c "\copy $SCHEMA.$table FROM '${table}.csv' WITH csv HEADER" postgresql://routesim_admin:$PSQL_PASSWORD@$PSQL_HOST:5432/$DB
done

# Import remaining tables
for filename in *.csv; do
  table="${filename%%.*}"
  if [[ ! ($table == "tenants" || $table == "solvers"  || $table == "simulators" || $table == "req_srcs" || $table ==  "scens") ]]  # https://stackoverflow.com/questions/12590490/splitting-filename-delimited-by-period
  then
    echo $table
    cat "$filename" | psql -c "\copy $SCHEMA.$table FROM $table.csv WITH csv HEADER"  postgresql://routesim_admin:$PSQL_PASSWORD@$PSQL_HOST:5432/$DB
  fi
done
