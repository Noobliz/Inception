#!/bin/bash

## Import secrets
MYSQL_PASSWORD=$(< /run/secrets/db_user_password_file | tr -d '\n')
MYSQL_ADMIN_PASSWORD=$(< /run/secrets/db_admin_password_file | tr -d '\n')

DB_HOST="mariadb"
DB_PORT=3306

echo "--- Démarrage de l'attente du service MariaDB ---"

# Utilisation de /dev/tcp/ pour tester la connexion (méthode native Bash)
until printf "" 2>/dev/null >/dev/tcp/$DB_HOST/$DB_PORT; do
    echo "MariaDB n'est pas prêt ($DB_HOST:$DB_PORT). Attente de 1 seconde..."
    sleep 1
done

echo "--- MariaDB est disponible. ---"
# Chemin vers le dossier WordPress
WP_PATH="/var/www/html/wordpress"
chown -R www-data:www-data /var/www/html/wordpress

if [ $? -ne 0 ]; then
    echo "ERREUR: CHOWN a échoué. Problème de permissions ou chemin incorrect."
    exit 1
fi
# Vérification conditionnelle : si le wp-config.php n'existe pas, on l'initialise
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "--- Création du wp-config.php avec les variables d'environnement ---"

    # Génération dynamique des clés de sécurité (BONNE PRATIQUE)
    WP_KEYS=$(wget -q -O - https://api.wordpress.org/secret-key/1.1/salt/)

    # On utilise cat << EOF pour écrire le contenu complet du fichier en injectant les variables Bash
    cat << EOF > "$WP_PATH/wp-config.php"
<?php
/**
 * Les identifiants de la base de données
 */
define( 'DB_NAME',            '$MYSQL_DATABASE' );
define( 'DB_USER',            '$MYSQL_USER' );
define( 'DB_PASSWORD',        '$MYSQL_PASSWORD' );
define( 'DB_HOST',            'mariadb' ); 
define( 'DB_CHARSET',         'utf8' );
define( 'DB_COLLATE',         '' );

$WP_KEYS

\$table_prefix  = 'wp_';
define( 'WP_DEBUG', true );

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOF
    echo "--- Fichier wp-config.php créé ---"
fi

echo "--- Tentative de test de la configuration PHP-FPM ---"
# Lance le service PHP-FPM en avant-plan (PID 1) et remplace le processus du shell
exec "$@"