#!/bin/bash

set -e

function create_role_and_database() {
  local database=$(echo $1 | awk -F, '{print $1}')
  local username=$(echo $1 | awk -F, '{print $2}')
  local password=$(echo $1 | awk -F, '{print $3}')

  echo "[+] creating role $username for database $database with password ${password//?/*}..."

  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $username WITH PASSWORD '$password';
    CREATE DATABASE $database OWNER $username;
EOSQL
}

if [ -n "$POSTGRES_INIT_DATABASES" ]; then
  for db in $(echo $POSTGRES_INIT_DATABASES | tr ':' ' '); do
    create_role_and_database $db
  done
fi
