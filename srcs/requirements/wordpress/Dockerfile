
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