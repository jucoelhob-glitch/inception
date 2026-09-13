#!/bin/bash
set -e

DB_PASSWORD="$(cat /run/secrets/db_password)"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking=0 &
pid=$!

for i in $(seq 1 30); do
    mysqladmin --protocol=socket -u root ping >/dev/null 2>&1 && break
    sleep 1
done

if ! mysqladmin --protocol=socket -u root ping >/dev/null 2>&1; then
    echo "MariaDB não iniciou a tempo." >&2
    exit 1
fi

mysql_cmd="mysql --protocol=socket -u root"
if ! $mysql_cmd -e "SELECT 1" >/dev/null 2>&1; then
    mysql_cmd="mysql --protocol=socket -u root -p$DB_ROOT_PASSWORD"
fi

$mysql_cmd -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"
$mysql_cmd -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
$mysql_cmd -e "ALTER USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
$mysql_cmd -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';"
$mysql_cmd -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';"
$mysql_cmd -e "FLUSH PRIVILEGES;"

mysqladmin --protocol=socket -u root -p"$DB_ROOT_PASSWORD" shutdown || kill "$pid"
wait "$pid" 2>/dev/null || true

exec mysqld --user=mysql --bind-address=0.0.0.0 --console