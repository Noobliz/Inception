#!/bin/bash

set -e

## Create SSL repository
mkdir -p /etc/nginx/ssl
mkdir -p /etc/nginx/nginx

## Generate SSL Certificate only if it's not existing
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=FR/ST=France/L=Angouleme/O=42School/OU=student/CN=$DOMAIN_NAME"
fi

# ## Apply NGINX Conf
envsubst '$DOMAIN_NAME' < /etc/nginx/conf.d/nginx.conf > /etc/nginx/conf.d/default.conf
# ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default


## Test Nginx configuration
nginx -t

## Launch Nginx Configuration
exec "$@"