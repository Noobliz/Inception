# FROM debian:bookworm

# #PHP-FPM is a intermediary between nginx and any request in php
# #nginx doesn't know how to execute php, so it will transfer the request
# #via a socket to PHP-FPM
# #PHP-FPM will execute the code and generate an HTML from it
# #then it will send the html to nginx and nginx transfer it back to client

# #install necessary tools (wget/curl) and of php-fpm
# RUN apt-get update -y && apt-get install -y \
#         wget \
#         curl \
#         tar \
#         php \
#         php-fpm \
#         php-mysql \
#         php-cli \
#         php-curl \
#         php-gd \
#         php-mbstring \
#         php-zip \
#     && rm -rf /var/lib/apt/lists/*

# # Crée le répertoire où PHP-FPM essaie d'écrire son PID file et donne la propriété à www-data
# RUN mkdir -p /run/php/ && chown -R www-data:www-data /run/php

# #RUN wget -q -O /tmp/wordpress.tar.gz https://fr.wordpress.org/wordpress-6.8.3-fr_FR.tar.gz
# RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
#     chmod +x wp-cli.phar && \
#     mv wp-cli.phar /usr/local/bin/wp

# WORKDIR /var/www/html
# # Décompression du fichier dans /var/www/html
# # L'option -C permet de spécifier le répertoire de destination
# # RUN mkdir -p /var/www/html && \
# #     tar -xzf /tmp/wordpress.tar.gz -C /var/www/html/

# # La commande chown définit www-data comme propriétaire (utilisateur et groupe)
# # www-data est l'utilisateur sous lequel PHP-FPM va s'exécuter
# RUN chown -R www-data:www-data /var/www/html/wordpress 
# # && \
# #     rm /tmp/wordpress.tar.gz

# COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# COPY setup.sh /usr/local/bin
# RUN chmod u+x /usr/local/bin/setup.sh && \
#     chown -R root:root /var/www/html

# ENTRYPOINT ["/usr/local/bin/setup.sh"]
# #Php-fpm will stay in foreground (PID 1)
# CMD ["php-fpm8.2", "-F"]

FROM debian:bookworm

# Installation de PHP et ses extensions
# On retire 'wget' (on utilise curl plus bas) et 'mariadb-client' (pas nécessaire)
RUN apt-get update -y && apt-get install -y \
        curl \
        tar \
        php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-cli \
        php8.2-curl \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-zip \
    && rm -rf /var/lib/apt/lists/*

# Création du répertoire PID
RUN mkdir -p /run/php/ && chown -R www-data:www-data /run/php

# Installation de WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Configuration du dossier de travail
WORKDIR /var/www/html

# Copie de la configuration PHP-FPM
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copie du script de démarrage
COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Création du dossier racine
RUN mkdir -p /var/www/html/wordpress

ENTRYPOINT ["/usr/local/bin/setup.sh"]

# Lancement de PHP-FPM
CMD ["php-fpm8.2", "-F"]