#!/bin/bash

## Import secrets
MYSQL_PASSWORD=$(< /run/secrets/db_user_password_file)
MYSQL_ADMIN_PASSWORD=$(< /run/secrets/db_admin_password_file)
MYSQL_ROOT_PASSWORD=$(< /run/secrets/db_root_password_file)

set -e
#check if the dir mysql already exists, if not, it's the first exec
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "---initializing data base---"
    #initialising default repo
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    #launch mariadb temporrly so mysql can connect to it
    mysqld --user=mysql &
    #we wait for mariadb to start
    while ! mysqladmin ping -h localhost --silent; do
        echo "waiting for mariadb to start..."
        sleep 1
    done
        echo "mariadb is ready to be set up"

    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
    # create database for wordpress
    CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
    
    #Cmd 1 : create standard user for wordpress
    CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
    GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

    # cmd 2: create admin user for wordpress
    CREATE USER '$MYSQL_ADMIN_USER'@'%' IDENTIFIED BY '$MYSQL_ADMIN_PASSWORD';
    GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ADMIN_USER'@'%' WITH GRANT OPTION; # Droits sur toutes les bases

    FLUSH PRIVILEGES;
    "
    #stops mariadb service
    mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
fi

#exec will replace the actual process (the script) by the new one (mysqld)
# without creating a sub-process
exec "$@"