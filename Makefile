## —— 🥦 The Greenweek Makefile 🥦 —————————————————————————————————————————————

# Executables: local only
DOCKER        = docker
DOCKER_COMP   = docker-compose

# Executables
EXEC_PHP_CONT = $(DOCKER_COMP) exec php
COMPOSER      = $(EXEC_PHP_CONT) composer
PHP           = $(EXEC_PHP_CONT) php

# Alias
SYMFONY       = $(PHP) bin/console

# Misc
.DEFAULT_GOAL = help
.PHONY        = *

## —— Targets 🚀 ———————————————————————————————————————————————————————————————

help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
up: ## Start the docker hub (PHP,Caddy)
	$(DOCKER_COMP) up -d

down: ## Stop the docker hub
	$(DOCKER_COMP) down --remove-orphans

logs: ## Show the live logs
	$(DOCKER_COMP) logs -f

## —— PHP 🐘 ———————————————————————————————————————————————————————————————————
php: ## Call the PHP executable of the php Docker container
	# to pass arguments to the target just do for exemple: make php a=-i | grep timezone
	$(eval a ?= '-v')
	$(PHP) $(a)

## —— Composer 🧙‍♂️ ————————————————————————————————————————————————————————————
composer: ## Call composer
	# to pass arguments to the target just do for exemple: make composer a=show | grep console
	$(COMPOSER) $(a)

install: composer.lock ## Install vendors according to the current composer.lock file
	$(COMPOSER) install --no-progress --prefer-dist --optimize-autoloader

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## Call the symfony command
	# to pass arguments to the target just do for example: make sf a="debug:container parameter_bag"
	$(SYMFONY) $(a)

cc: ## Clear the cache. DID YOU CLEAR YOUR CACHE????
	$(SYMFONY) c:c

warmup: ## Warmup the cache
	$(SYMFONY) cache:warmup

assets: purge ## Install the assets with symlinks in the public folder
	$(SYMFONY) assets:install public/ --symlink --relative

## —— Project 🐝 ———————————————————————————————————————————————————————————————
start: up ## Start docker

stop: down ## Stop docker

fix-perms: ## Fix permissions of all var files
	$(EXEC_PHP_CONT) chmod -R 777 var/*

purge: ## Purge cache and logs
	$(EXEC_PHP_CONT) rm -rf var/cache/* var/logs/*
