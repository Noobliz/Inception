FROM debian:bullseye

#installing mariadb and cleaning apt cache
RUN apt-get update -y && apt-get install mariadb-server -y && \
    rm -rf /var/lib/apt/lists/*

#copy and make the script executable
COPY init.sh /usr/local/bin
RUN chmod u+x /usr/local/bin/init.sh

#define the entrypoint and the cmd that runs mariadb as PID 1 (and not daemon)
ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["mysqld"]