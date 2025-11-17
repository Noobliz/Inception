FROM debian:bullseye

#installing mariadb and cleaning apt cache
RUN apt-get update -y && apt-get install mariadb-server -y && \
    rm -rf /var/lib/apt/lists/*
# Créer le répertoire de socket (PID 1 le lira)
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld
COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf
#copy and make the script executable
COPY init.sh /usr/local/bin
RUN chmod u+x /usr/local/bin/init.sh

#define the entrypoint and the cmd that runs mariadb as PID 1 (and not daemon)
ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["mysqld"]