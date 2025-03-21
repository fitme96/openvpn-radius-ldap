FROM freeradius/freeradius-server
COPY docker-entrypoint.sh /
COPY yl_server /etc/raddb/sites-enabled/
RUN chmod +x docker-entrypoint.sh
