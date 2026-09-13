*This project has been created as part of the 42 curriculum by jucoelho.*

# Inception

## Description

Inception is a system administration project that builds a small WordPress
infrastructure with Docker Compose. The mandatory stack contains three custom
images, one service per container:

- NGINX: the only public entrypoint, serving HTTPS on port 443 with TLS 1.2 or TLS 1.3.
- WordPress with PHP-FPM: the application server, without NGINX.
- MariaDB: the WordPress database, without NGINX.

The containers communicate through a private bridge network. WordPress files
and the MariaDB database are stored in separate named volumes backed by
directories under `DATA_PATH`.

## Instructions

Run the project inside a Linux virtual machine with Docker Engine, the Docker
Compose plugin, and `make` installed.

1. Copy `srcs/.env.example` to `srcs/.env`.
2. Create the four local files under `secrets/`: `db_password.txt`,
   `db_root_password.txt`, `wp_admin_password.txt`, and `wp_user_password.txt`.
3. Set `DOMAIN_NAME` and `DATA_PATH` in `srcs/.env`.
4. Add the domain to `/etc/hosts`, for example:

	```text
	127.0.0.1 jucoelho.42.fr
	```

4. Build and start the stack:

	```sh
	make
	```

Useful commands:

```sh
make build   # build the three images
make up      # create data directories and start the stack
make logs    # follow service logs
make down    # stop and remove containers
make clean   # remove containers, volumes, and orphan containers
make re      # clean, rebuild, and start
```

Open `https://jucoelho.42.fr` and `https://jucoelho.42.fr/wp-admin/` after
startup. The development certificate is self-signed, so the browser may show a
warning.

## Project Design

All service images are built from Debian Bookworm Dockerfiles. No ready-made
application image is used. Entrypoint scripts run the service as PID 1, and
the containers use `restart: unless-stopped`. Only NGINX publishes a host port.

### Virtual Machines vs Docker

A virtual machine includes a complete guest operating system and has stronger
isolation but needs more resources. Docker containers share the host kernel,
start faster, and isolate each service with less overhead. This project runs
inside a VM as required by the subject and uses Docker for the services.

### Secrets vs Environment Variables

Environment variables are suitable for non-sensitive configuration such as the
domain and database name. Passwords are stored locally in Docker Secret files
under `secrets/` and mounted at `/run/secrets` only in the services that need
them. Both `srcs/.env` and `secrets/` are ignored and must not be committed.
Create the secret files locally before running `make`.

### Docker Network vs Host Network

A custom bridge network gives containers private DNS-based communication and
requires explicit port publishing. Host networking removes that isolation and
would expose services directly. This project uses a custom bridge network and
publishes only port 443 through NGINX.

### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker, while bind mounts map an explicit host
directory. The project uses named volumes with the local driver's bind option:
this satisfies the volume requirement while keeping persistent data under the
configured `DATA_PATH`.

## Documentation

- [USER_DOC.md](USER_DOC.md): operation, access, credentials, and checks.
- [DEV_DOC.md](DEV_DOC.md): setup, build, and data management.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose specification](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WordPress CLI documentation](https://wp-cli.org/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [OpenSSL documentation](https://www.openssl.org/docs/)

AI was used to compare the implementation with the subject, identify startup
and configuration issues, and review the Docker and documentation structure.
Every change was checked against the local files and validation commands.