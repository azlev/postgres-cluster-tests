#!/bin/bash
set -eo pipefail


# wait for master
export PGPASSWORD="$POSTGRES_PASSWORD"
until pg_isready -h master -U $POSTGRES_USER; do sleep 2; done

# setup standby
pg_ctl -D /var/lib/postgresql/data stop -m fast
rm -rf /var/lib/postgresql/data/*
export PGPASSWORD="$PG_REP_PASSWORD"
pg_basebackup -d "host=master user=$PG_REP_USER application_name=$(hostname)" \
	-v \
	-P \
	-S $(hostname) -C \
	-R \
	--wal-method=stream \
	-D /var/lib/postgresql/data

pg_ctl -D /var/lib/postgresql/data start

