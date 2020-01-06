# OpenEdx E-Commerce
EDXEC_RELEASE               ?= master
EDXEC_ARCHIVE_URL           ?= https://github.com/edx/ecommerce/archive/master.tar.gz
FLAVOR                      ?= bare
FLAVORED_EDXEC_RELEASE_PATH  = releases/$(shell echo ${EDXEC_RELEASE} | sed -E "s|\.|/|")/$(FLAVOR)
EDXEC_RELEASE_REF           ?= master
EDXEC_DOCKER_TAG            ?= latest

# Get local user ids
DOCKER_UID = $(shell id -u)
DOCKER_GID = $(shell id -g)

# Docker
COMPOSE          = \
  DOCKER_UID=$(DOCKER_UID) \
  DOCKER_GID=$(DOCKER_GID) \
  FLAVORED_EDXEC_RELEASE_PATH=$(FLAVORED_EDXEC_RELEASE_PATH) \
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

$(FLAVORED_EDXEC_RELEASE_PATH)/data/assets/.keep:
	mkdir -p $(FLAVORED_EDXEC_RELEASE_PATH)/data/assets
	touch $(FLAVORED_EDXEC_RELEASE_PATH)/data/assets/.keep

$(FLAVORED_EDXEC_RELEASE_PATH)/data/media/.keep:
	mkdir -p $(FLAVORED_EDXEC_RELEASE_PATH)/data/media
	touch $(FLAVORED_EDXEC_RELEASE_PATH)/data/media/.keep

$(FLAVORED_EDXEC_RELEASE_PATH)/src/.keep:
	mkdir -p $(FLAVORED_EDXEC_RELEASE_PATH)/src
	touch $(FLAVORED_EDXEC_RELEASE_PATH)/src/.keep

$(FLAVORED_EDXEC_RELEASE_PATH)/src/README.rst:
	@echo -e "$(COLOR_INFO)Downloading sources archive...$(COLOR_RESET)"
	curl -sLo /tmp/ecommerce.tgz $(EDXEC_ARCHIVE_URL)
	tar xzf /tmp/ecommerce.tgz -C $(FLAVORED_EDXEC_RELEASE_PATH)/src --strip-components=1

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
	@echo -e "$(COLOR_WARNING)Removing database...$(COLOR_RESET)"
	${MAKE} stop
	$(COMPOSE) rm mysql
	@echo -e "$(COLOR_WARNING)Removing downloaded sources...$(COLOR_RESET)"
	rm -fr $(FLAVORED_EDXEC_RELEASE_PATH)/src
	@echo -e "$(COLOR_WARNING)Removing collected assets...$(COLOR_RESET)"
	rm -fr $(FLAVORED_EDXEC_RELEASE_PATH)/data
.PHONY: clean

dev: info
dev:  ## Run development server
	@echo -e "$(COLOR_INFO)Starging development server...$(COLOR_RESET)"
	$(COMPOSE) up -d app
	$(COMPOSE_RUN) dockerize -wait tcp://mysql:3306 -timeout 60s
	$(COMPOSE_RUN) dockerize -wait tcp://app:8000 -timeout 60s
.PHONY: dev

dev-assets: tree
dev-assets:  ## Handle development assets
	@echo -e "$(COLOR_INFO)Handling assets for development...$(COLOR_RESET)"
	$(COMPOSE_RUN) node npm install
	$(COMPOSE_RUN) node node_modules/.bin/bower install
	$(MANAGE) update_assets --skip-collect || echo "Assets update failed and will be ignored (old release)"
	$(COMPOSE_RUN) node node_modules/.bin/r.js -o build.js
	$(MANAGE) collectstatic --noinput
	$(MANAGE) compress --force
.PHONY: dev-assets

info:  ## Get activated release info
	@echo -e "\n.:: OPENEDX-ECOMMERCE-DOCKER ::.\n"
	@echo -e "== Active configuration ==\n"
	@echo -e "* EDXEC_RELEASE                : $(COLOR_INFO)$(EDXEC_RELEASE)$(COLOR_RESET)"
	@echo -e "* FLAVOR                       : $(COLOR_INFO)$(FLAVOR)$(COLOR_RESET)"
	@echo -e "* FLAVORED_EDXEC_RELEASE_PATH  : $(COLOR_INFO)$(FLAVORED_EDXEC_RELEASE_PATH)$(COLOR_RESET)"
	@echo -e "* EDXEC_ARCHIVE_URL            : $(COLOR_INFO)$(EDXEC_ARCHIVE_URL)$(COLOR_RESET)"
	@echo -e "* EDXEC_RELEASE_REF            : $(COLOR_INFO)$(EDXEC_RELEASE_REF)$(COLOR_RESET)"
	@echo -e "* EDXEC_DOCKER_TAG             : $(COLOR_INFO)$(EDXEC_DOCKER_TAG)$(COLOR_RESET)"
	@echo -e ""
.PHONY: info

logs:  ## Follow application logs
	@$(COMPOSE) logs -f app
.PHONY: logs

fetch-src: \
  tree\
  $(FLAVORED_EDXEC_RELEASE_PATH)/src/README.rst
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
  $(FLAVORED_EDXEC_RELEASE_PATH)/data/assets/.keep \
  $(FLAVORED_EDXEC_RELEASE_PATH)/data/media/.keep \
  $(FLAVORED_EDXEC_RELEASE_PATH)/src/.keep
tree:  ## Build working tree
.PHONY: tree

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

