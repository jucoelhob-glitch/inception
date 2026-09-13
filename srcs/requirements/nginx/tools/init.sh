#!/bin/bash
set -e

if [ ! -f /etc/nginx/ssl/certificate.crt ] || [ ! -f /etc/nginx/ssl/private.key ]; then
	openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/ssl/private.key \
		-out /etc/nginx/ssl/certificate.crt \
		-subj "/C=BR/ST=SP/L=SP/O=42/CN=${DOMAIN_NAME}"
fi

sed -i "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf

for i in $(seq 1 30); do
	(echo > /dev/tcp/wordpress/9000) >/dev/null 2>&1 && break
	sleep 1
done

if ! (echo > /dev/tcp/wordpress/9000) >/dev/null 2>&1; then
	echo "PHP-FPM não ficou disponível a tempo." >&2
	exit 1
fi

exec nginx -g "daemon off;"