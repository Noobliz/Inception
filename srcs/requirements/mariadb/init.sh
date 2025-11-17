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
    
    # Lancement de MariaDB temporairement (en mode sécurisé/initialisation)
    #mysqld --user=mysql --skip-networking --skip-grant-tables --socket=/tmp/mysqld.sock &
    #mysqld --user=mysql --skip-networking --skip-grant-tables --socket=/tmp/mysqld.sock --datadir=/var/lib/mysql --skip-log-bin &
    #mysqld --user=mysql --skip-networking --skip-grant-tables --socket=/tmp/mysqld.sock --datadir=/var/lib/mysql --skip-log-bin --skip-config-file &
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$!
    
    # Attente du démarrage de MariaDB (en utilisant le socket)
    while ! mysqladmin ping -h localhost --socket=/tmp/mysqld.sock --silent; do
        echo "waiting for mariadb to start..."
        sleep 1
    done
    echo "mariadb is ready to be set up"

    # Exécution des commandes SQL (on doit utiliser le même socket si on n'a pas de réseau)
    # Note: On utilise root SANS mot de passe car --skip-grant-tables est actif.
    mysql -u root --socket=/tmp/mysqld.sock -e "
    
    # Définir le mot de passe root avant de créer d'autres utilisateurs
    # On utilise ALTER USER pour être compatible avec les versions récentes de MariaDB/MySQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';

    # Création des bases/utilisateurs (Les droits ne sont pas encore actifs pour le mot de passe root)
    CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
    
    #Cmd 1 : create standard user for wordpress
    CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
    GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

    # cmd 2: create admin user for wordpress
    CREATE USER '$MYSQL_ADMIN_USER'@'%' IDENTIFIED BY '$MYSQL_ADMIN_PASSWORD';
    GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ADMIN_USER'@'%' WITH GRANT OPTION;

    FLUSH PRIVILEGES;
    "
    # Arrêt du service temporaire (sans mot de passe, avec le socket)
    mysqladmin -u root --socket=/tmp/mysqld.sock shutdown
fi

# Le processus principal de MariaDB est lancé ici comme PID 1
exec "$@"