# User Documentation

## Services

The stack provides an HTTPS NGINX frontend, a WordPress application served by
PHP-FPM, and a MariaDB database. Only NGINX is exposed to the host on port 443.

## Start and Stop

From the repository root:

```sh
make
make down
```

Use `make logs` to follow service logs.

## Access

Add `127.0.0.1 jucoelho.42.fr` to `/etc/hosts` when testing on the local VM.
Visit `https://jucoelho.42.fr` for the site and
`https://jucoelho.42.fr/wp-admin/` for administration. The certificate is
self-signed, so a browser warning is expected in development.

## Credentials and Health

Credentials are kept in the local Docker Secret files under `secrets/`. The
non-sensitive local configuration is in `srcs/.env`; both locations must not be
committed. Check
the stack with `docker compose -f srcs/docker-compose.yml ps` and test HTTPS
with `curl -k -I https://jucoelho.42.fr`.