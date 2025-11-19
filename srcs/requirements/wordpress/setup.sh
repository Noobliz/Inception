#!/bin/bash

## Import secrets
MYSQL_PASSWORD=$(< /run/secrets/db_user_password_file | tr -d '\n')
# MYSQL_ADMIN_PASSWORD=$(< /run/secrets/db_admin_password_file | tr -d '\n')
WP_ADMIN_PASSWORD=$(< /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(< /run/secrets/wp_user_password)


set -e

echo "=== Start WP Setup ==="
cd /var/www/html/wordpress

## Download wp only if is not existing
if [ ! -f wp-config.php ] && [ ! -d wp-admin ]; then
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

	echo "=== Waiting DB to be ready ==="
	## Wait db to be ready
	sleep 10

	echo "=== Instal WP ==="
	## Wordpress Installation
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
chown -R www-data:www-data /var/www/html

echo "--- Tentative de test de la configuration PHP-FPM ---"
# Lance le service PHP-FPM en avant-plan (PID 1) et remplace le processus du shell
exec "$@"