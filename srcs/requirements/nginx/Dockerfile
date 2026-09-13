FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

EXPOSE 443

ENTRYPOINT ["/init.sh"]