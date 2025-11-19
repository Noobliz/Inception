#!/bin/bash

## Import secrets
MYSQL_PASSWORD=$(< /run/secrets/db_user_password_file | tr -d '\n')
MYSQL_ADMIN_PASSWORD=$(< /run/secrets/db_admin_password_file | tr -d '\n')
MYSQL_ROOT_PASSWORD=$(< /run/secrets/db_root_password_file | tr -d '\n')

set -e
# Vérifie si le dossier de données de la DB existe
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "--- Initialisation de la base de données ---"
    
    # Récupérer les variables du .env et les nettoyer (si elles contiennent des sauts de ligne)
    # MYSQL_DATABASE=$(echo "$MYSQL_DATABASE" | tr -d '\n')
    # MYSQL_USER=$(echo "$MYSQL_USER" | tr -d '\n')
    # MYSQL_ADMIN_USER=$(echo "$MYSQL_ADMIN_USER" | tr -d '\n')

    # 1. Initialisation du répertoire de données
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # 2. Lancement de MariaDB temporairement pour l'initialisation SQL
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$!
    
    # 3. Attente du démarrage du serveur (doit utiliser le même socket)
    while ! mysqladmin ping --silent; do
        echo "Attente du démarrage de MariaDB..."
        sleep 1
    done
    echo "MariaDB est prêt pour la configuration."

    # 4. Exécution des commandes SQL
    mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF
    
    # 5. Arrêt du service temporaire (sans mot de passe, avec le socket)
    mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown
    wait $MYSQL_PID
fi

# Le processus principal de MariaDB est lancé ici comme PID 1
exec mysqld --user=mysql --datadir=/var/lib/mysql