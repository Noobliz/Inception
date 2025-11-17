FROM debian:bullseye

#PHP-FPM is a intermediary between nginx and any request in php
#nginx doesn't know how to execute php, so it will transfer the request
#via a socket to PHP-FPM
#PHP-FPM will execute the code and generate an HTML from it
#then it will send the html to nginx and nginx transfer it back to client

#install necessary tools (wget/curl) and of php-fpm
RUN apt-get update -y && apt-get install -y \
        wget \
        tar \
        php7.4 \
        php7.4-fpm \
        php7.4-mysql \
        php7.4-cli \
        php7.4-curl \
        php7.4-gd \
        php7.4-mbstring \
        php7.4-zip \
    && rm -rf /var/lib/apt/lists/*

#RUN apt-get update -y && \
    #apt-get install -y tar && \
    #rm -rf /var/lib/apt/lists/*

RUN wget -q -O /tmp/wordpress.tar.gz https://fr.wordpress.org/wordpress-6.8.3-fr_FR.tar.gz

# Décompression du fichier dans /var/www/html
# L'option -C permet de spécifier le répertoire de destination
RUN mkdir -p /var/www/html && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/html/

# La commande chown définit www-data comme propriétaire (utilisateur et groupe)
# www-data est l'utilisateur sous lequel PHP-FPM va s'exécuter
RUN chown -R www-data:www-data /var/www/html/wordpress && \
    rm /tmp/wordpress.tar.gz

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY setup.sh /usr/local/bin
RUN chmod u+x /usr/local/bin/setup.sh

ENTRYPOINT ["/usr/local/bin/setup.sh"]
#Php-fpm will stay in foreground (PID 1)
CMD ["/usr/sbin/php-fpm7.4", "-F"]