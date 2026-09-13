NAME = inception
COMPOSE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env
DATA_PATH = $(shell sed -n 's/^DATA_PATH=//p' srcs/.env)

all: up

prepare:
	mkdir -p "$(DATA_PATH)/wordpress" "$(DATA_PATH)/mariadb"
	@test -f secrets/db_password.txt
	@test -f secrets/db_root_password.txt
	@test -f secrets/wp_admin_password.txt
	@test -f secrets/wp_user_password.txt

build:
	$(COMPOSE) build

up: prepare
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down --volumes --remove-orphans

re: clean build up

.PHONY: all prepare build up down logs clean re