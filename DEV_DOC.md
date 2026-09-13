# Developer Documentation

## Prerequisites

Use a Linux virtual machine with Docker Engine, the Docker Compose plugin, and
`make`. Copy `srcs/.env.example` to the ignored file `srcs/.env` and create the
four local Docker Secret files under `secrets/`. These files are ignored by
Git and must never be committed.

The secret files are `db_password.txt`, `db_root_password.txt`,
`wp_admin_password.txt`, and `wp_user_password.txt`. Each file contains only
the corresponding password. Compose mounts them under `/run/secrets`.

## Build and Launch

```sh
make build
make up
make logs
make down
```

The Makefile checks the secret files and uses `srcs/docker-compose.yml`. Each service is built from its own
Dockerfile under `srcs/requirements`. The `prepare` step creates the two host
directories required by the bind-backed volumes.

## Container and Data Management

Useful commands include:

```sh
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml exec wordpress wp core is-installed --allow-root --path=/var/www/html
docker compose -f srcs/docker-compose.yml down --remove-orphans
make clean
```

WordPress files persist in `${DATA_PATH}/wordpress` and MariaDB data persists in
`${DATA_PATH}/mariadb`. Removing those directories deletes the application data
and forces a fresh installation.