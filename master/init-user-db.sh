#!/bin/bash
set -e

echo "host replication all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE $PG_REP_USER LOGIN PASSWORD '$PG_REP_PASSWORD' REPLICATION;
    SELECT pg_reload_conf();
EOSQL
