# OpenEdx E-Commerce
EDX_EC_ARCHIVE_URL ?= https://github.com/edx/ecommerce/archive/master.tar.gz
EDX_EC_RELEASE_REF ?= master
EDX_EC_DOCKER_TAG  ?= latest

# Get local user ids
DOCKER_UID = $(shell id -u)
DOCKER_GID = $(shell id -g)

# Docker
COMPOSE          = \
  DOCKER_UID=$(DOCKER_UID) \
  DOCKER_GID=$(DOCKER_GID) \
  EDX_EC_ARCHIVE_URL=$(EDX_EC_ARCHIVE_URL) \
  EDX_EC_RELEASE_REF=$(EDX_EC_ARCHIVE_URL) \
  EDX_EC_DOCKER_TAG=$(EDX_EC_DOCKER_TAG) \
  docker-compose
COMPOSE_RUN      = $(COMPOSE) run --rm -e HOME="/tmp"
COMPOSE_EXEC     = $(COMPOSE) exec
MANAGE           = $(COMPOSE_RUN) app python manage.py

# Terminal colors
COLOR_DEFAULT = \033[0;39m
COLOR_ERROR   = \033[0;31m
COLOR_INFO    = \033[0;36m
COLOR_RESET   = \033[0m
COLOR_SUCCESS = \033[0;32m
COLOR_WARNING = \033[0;33m

# Shell
SHELL=bash


default: help

data/assets/.keep:
	mkdir -p data/assets
	touch data/assets/.keep

data/media/.keep:
	mkdir -p data/media
	touch data/media/.keep

src/.keep:
	mkdir -p src
	touch src/.keep

src/README.rst:
	@echo -e "$(COLOR_INFO)Downloading sources archive...$(COLOR_RESET)"
	curl -sLo /tmp/ecommerce.tgz $(EDX_EC_ARCHIVE_URL)
	tar xzf /tmp/ecommerce.tgz -C ./src --strip-components=1

bootstrap: \
  clean \
  build \
  dev-assets \
  migrate
bootstrap:  ## Bootstrap the application
	@echo -e "$(COLOR_SUCCESS)Project bootstrapped successfully.$(COLOR_RESET)"
	@echo -e "Now try to run the development server using: $(COLOR_INFO)make dev$(COLOR_RESET)"
.PHONY: bootstrap

build: \
  info \
  tree \
  fetch-src
build:  ## Build docker image
	@echo -e "$(COLOR_INFO)Starting Docker image build...$(COLOR_RESET)"
	$(COMPOSE) build app
.PHONY: build

clean:  ## Remove downloaded sources, assets and database
	@echo -e "$(COLOR_WARNING)Removing downloaded sources...$(COLOR_RESET)"
	rm -fr src
	@echo -e "$(COLOR_WARNING)Removing collected assets...$(COLOR_RESET)"
	rm -fr data
	@echo -e "$(COLOR_WARNING)Removing database...$(COLOR_RESET)"
	${MAKE} stop
	$(COMPOSE) rm mysql
.PHONY: clean

dev: info
dev:  ## Run development server
	@echo -e "$(COLOR_INFO)Starging development server...$(COLOR_RESET)"
	$(COMPOSE) up -d app
	$(COMPOSE_RUN) dockerize -wait tcp://mysql:3306 -timeout 60s
.PHONY: dev

dev-assets: tree
dev-assets:  ## Handle development assets
	@echo -e "$(COLOR_INFO)Handling assets for development...$(COLOR_RESET)"
	$(COMPOSE_RUN) node npm install
	$(COMPOSE_RUN) node node_modules/.bin/bower install
	$(MANAGE) update_assets --skip-collect
	$(COMPOSE_RUN) node node_modules/.bin/r.js -o build.js
	$(MANAGE) collectstatic --no-input
	$(MANAGE) compress --force
.PHONY: dev-assets

info:  ## Get activated release info
	@echo -e "\n.:: OPENEDX-ECOMMERCE-DOCKER ::.\n"
	@echo -e "== Active configuration ==\n"
	@echo -e "* EDX_EC_ARCHIVE_URL: $(COLOR_INFO)$(EDX_EC_ARCHIVE_URL)$(COLOR_RESET)"
	@echo -e "* EDX_EC_RELEASE_REF: $(COLOR_INFO)$(EDX_EC_RELEASE_REF)$(COLOR_RESET)"
	@echo -e "* EDX_EC_DOCKER_TAG: $(COLOR_INFO)$(EDX_EC_DOCKER_TAG)$(COLOR_RESET)"
	@echo -e ""
.PHONY: info

logs:  ## Follow application logs
	@$(COMPOSE) logs -f app
.PHONY: logs

fetch-src: \
  tree\
  src/README.rst
fetch-src:  ## Fetch OpenEdx ECommerce sources
	@echo -e "$(COLOR_INFO)\
	OpenEdx ECommerce project sources have been downloaded. \
	Use 'make clean' to remove them. \
	$(COLOR_RESET)"
.PHONY: fetch-src

migrate:  ## Run E-Commerce migrations
	@echo -e "$(COLOR_INFO)Running database migrations...$(COLOR_RESET)"
	$(COMPOSE) up -d mysql
	$(COMPOSE_RUN) dockerize -wait tcp://mysql:3306 -timeout 60s
	$(MANAGE) migrate
.PHONY: migrate

status:  ## Get containers status
	@$(COMPOSE) ps
.PHONY: status

stop:  ## Stop development server
	$(COMPOSE) stop
.PHONY: stop

tree: \
  data/assets/.keep \
  data/media/.keep \
  src/.keep
tree:  ## Build working tree
.PHONY: tree

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

