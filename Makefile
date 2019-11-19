EDX_EC_ARCHIVE_URL ?= https://github.com/edx/ecommerce/archive/master.tar.gz

default: help

src/.keep:
	mkdir -p src
	touch src/.keep

src/README.rst:
	curl -Lo /tmp/ecommerce.tgz $(EDX_EC_ARCHIVE_URL)
	tar xzf /tmp/ecommerce.tgz -C ./src --strip-components=1

build: \
  tree \
  fetch-src
build:  ## Build docker image
	docker build -t edxec:latest .
.PHONY: build

clean:  ## Remove downloaded sources
	rm -fr src
.PHONY: clean

fetch-src: src/README.rst
fetch-src:  ## Fetch OpenEdx ECommerce sources
	@echo "OpenEdx ECommerce project sources have already been downloaded"
.PHONY: fetch-src

tree: src/.keep
tree:  ## Build working tree
.PHONY: tree

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

