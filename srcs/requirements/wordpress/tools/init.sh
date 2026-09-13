#!/bin/bash
set -e

DB_PASSWORD="$(cat /run/secrets/db_password)"
WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"

attempt=0
until mysql -h mariadb -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1" >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 30 ]; then
        echo "MariaDB não ficou disponível a tempo." >&2
        exit 1
    fi
    echo "Aguardando MariaDB..."
    sleep 2
done

echo "MariaDB pronto!"

if [ ! -f "/var/www/html/wp-config.php" ] || ! wp core is-installed --allow-root --path="/var/www/html" >/dev/null 2>&1; then
    echo "Configurando WordPress..."
    cd /var/www/html

    if [ ! -f "/var/www/html/wp-load.php" ]; then
        wget -q https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz
        tar -xzf /tmp/latest.tar.gz --strip-components=1 -C /var/www/html
        rm -f /tmp/latest.tar.gz
    fi

    wp config create --allow-root \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="mariadb" \
        --path="/var/www/html" \
        --force

    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --path="/var/www/html" \
        --skip-email
fi

if ! wp user get "$WP_USER" --allow-root --path="/var/www/html" >/dev/null 2>&1; then
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root \
        --path="/var/www/html"
fi

chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F