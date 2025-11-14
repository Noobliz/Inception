FROM debian:bullseye

RUN apt update -y && apt install -y nginx openssl gettext\
    && rm -rf /var/lib/apt/lists/*

#SETUP SSL KEY
# RUN mkdir -p /etc/nginx/ssl
# COPY ./conf/nginx.crt /etc/nginx/ssl/
# COPY ./conf/nginx.key /etc/nginx/ssl/

#CREATE /var/run/nginx DIRECTORY AND COPY NGINX CONFIG
RUN mkdir -p /var/run/nginx
COPY ./conf/nginx.conf /etc/nginx/conf.d

#SET PORT 443 FOR INTERNET LIKE SUBJECT ASK
EXPOSE 443


COPY nginx_setup.sh /nginx_setup.sh
RUN chmod +x /nginx_setup.sh

ENTRYPOINT ["/nginx_setup.sh"]
#LAUNCH NGINX ("-g" ALLOW FOR EDIT THE MAIN FILE CONFIG ; "daemon off" ALLOW NGINX TO RUN IN THE FOREGROUND)
CMD ["nginx", "-g", "daemon off;"]

