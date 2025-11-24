#!/bin/bash

## Import secrets
MYSQL_PASSWORD=$(< /run/secrets/db_user_password_file | tr -d '\n')
# MYSQL_ADMIN_PASSWORD=$(< /run/secrets/db_admin_password_file | tr -d '\n')
WP_ADMIN_PASSWORD=$(< /run/secrets/wp_admin_password | tr -d '\n')
WP_USER_PASSWORD=$(< /run/secrets/wp_user_password | tr -d '\n')


set -e

echo "=== Start WP Setup ==="
cd /var/www/html/wordpress

## Download wp only if is not existing
if [ ! -f wp-config.php ] && [ ! -d wp-admin ]; then
	echo "=== Waiting DB to be ready ==="
	DB_HOST="mariadb"
    DB_PORT=3306
    echo "=== Waiting for MariaDB ($DB_HOST:$DB_PORT) ==="
    until printf "" 2>/dev/null >/dev/tcp/$DB_HOST/$DB_PORT; do
        echo "MariaDB n'est pas prêt. Attente de 3 secondes..."
        sleep 3
    done
	echo "=== ✅ MariaDB est disponible. ==="
	echo "=== DL wp==="
	wp core download --allow-root

	## Wordpress Configuration
	wp config create \
	--dbname="$MYSQL_DATABASE" \
	--dbuser="$MYSQL_USER" \
	--dbpass="$MYSQL_PASSWORD" \
	--dbhost="mariadb:3306" \
	--allow-root
	echo "=== ✅ WP configurated ==="

	sed -i "2i \$_SERVER['HTTPS'] = 'on';" wp-config.php
	echo "=== Instal WP ==="
	wp core install \
	--url="https://$DOMAIN_NAME" \
	--title="$WP_TITLE" \
	--admin_user="$WP_ADMIN_USER" \
	--admin_password="$WP_ADMIN_PASSWORD" \
	--admin_email="$WP_ADMIN_EMAIL" \
	--allow-root
	echo "=== ✅ Wordpress instaled ✅ ==="

	echo "=== Create second user ==="
	## Create an second user
	wp user create \
	"$WP_USER" \
	"$WP_USER_EMAIL" \
	--user_pass="$WP_USER_PASSWORD" \
	--role=editor \
	--allow-root
fi

echo "=== Correct permissions ==="
chown -R www-data:www-data /var/www/html/wordpress
chmod 755 /var/www/html/wordpress

echo "--- Tentative de test de la configuration PHP-FPM ---"
# Lance le service PHP-FPM en avant-plan (PID 1) et remplace le processus du shell
exec "$@"