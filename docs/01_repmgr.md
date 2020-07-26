Using Replication Manager

[Documentation](https://repmgr.org/docs/current/index.html)

```
psql -U postgres -h 127.0.0.1 <<EOF
CREATE ROLE repmgr SUPERUSER LOGIN PASSWORD 'postgres';
CREATE DATABASE repmgr owner repmgr;
EOF

docker-compose exec master bash -c '
echo "node_id=1
node_name=master
conninfo=\'host=master user=repmgr dbname=repmgr password=123456\'
data_directory=\'/var/lib/postgresql/data\'" > /etc/repmgr.conf
su - postgres -c "repmgr -f /etc/repmgr.conf primary register"
'

