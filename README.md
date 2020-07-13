```
docker-compose up
export PGPASSWORD=postgres
until [[ $(psql -U postgres -h 127.0.0.1 -t -A -c "select count(*) from pg_stat_replication") = 3 ]]; do
  echo "Waiting for the 3 standbys to show up";
  sleep 2;
done
command=$(
psql -U postgres -h 127.0.0.1 -t -A <<EOF
select 'ALTER SYSTEM SET synchronous_standby_names = ''2 ("' || (array_agg(application_name))[1] || '","' || (array_agg(application_name))[2] || '","' || (array_agg(application_name))[3] || '")'';' FROM pg_stat_replication;
EOF
)
psql -U postgres -h 127.0.0.1 -t -A <<EOF
$command
ALTER SYSTEM SET log_duration = on;
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET synchronous_commit = 'remote_apply';
SELECT pg_reload_conf();
EOF
```

Now stop all, and create a separate filesystem to ro2:

```
docker-compose stop
sudo mv data/ro2 data/ro2-old
sudo mkdir data/ro2
sudo python -c "f = open('data/ro2.xfs', 'w');f.truncate(4 * 1024 **3);f.close();"
sudo mkfs.xfs data/ro2.xfs
sudo mount -o loop data/ro2.xfs data/ro2
sudo find data/ro1 -mindepth 1 -maxdepth 1 -exec mv '{}' data/ro2 ';'
sudo rm -rf data/ro2-old
docker-compose up
```

now open 2 terminals
first:
```
export PGPASSWORD=postgres
psql -U postgres -h 127.0.0.1 -c "CREATE TABLE test(id serial);"
while :; do psql -U postgres -h 127.0.0.1 -c "BEGIN; INSERT INTO test VALUE (DEFAULT); COMMIT;"; sleep 2; done
```

second:
```
sudo xfs_freeze -f data/ro2
```

Now observe.

