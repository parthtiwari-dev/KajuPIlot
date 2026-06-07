# KajuPilot -- Windows-friendly dev command menu
#
# First run:
#   make build
#   make up
#   make migrate
#   make health
#   make run

.PHONY: help \
        env env-check hash doctor \
        build build-nc up up-full down restart ps logs migrate health \
        prod-build prod-up prod-down prod-restart prod-ps prod-logs prod-migrate prod-health \
        run phone devices apk release-apk release release-oracle \
        api-build api-test api-audit admin-build admin-audit checks

DEVICE_ID ?= 1592533185000B8
ADMIN_PASSWORD ?= kaju_admin_dev_password
API_BASE_URL ?= http://127.0.0.1:3000/api/v1
ORACLE_IP ?= 141.148.213.89
ORACLE_API_BASE_URL ?= https://api.$(ORACLE_IP).sslip.io/api/v1
ENV_FILE ?= .env
DEPLOY_TARGET ?= local
COMPOSE_DEV = docker compose --env-file $(ENV_FILE) -f docker-compose.yml -f docker-compose.dev.yml
COMPOSE_PROD = docker compose --env-file $(ENV_FILE) -f docker-compose.yml
ifeq ($(DEPLOY_TARGET),production)
COMPOSE = $(COMPOSE_PROD)
else ifeq ($(DEPLOY_TARGET),prod)
COMPOSE = $(COMPOSE_PROD)
else
COMPOSE = $(COMPOSE_DEV)
endif
PS = powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1

help:
	@echo KajuPilot dev commands
	@echo TARGET
	@echo   make up                         Local dev stack with localhost ports
	@echo   make up DEPLOY_TARGET=prod      Production compose stack, no dev port override
	@echo   make prod-up                    Production compose stack, explicit target
	@echo FIRST RUN
	@echo   make env        Create .env if missing
	@echo   make build      Build API and admin Docker images
	@echo   make up         Start Postgres, Redis, API, and admin
	@echo   make migrate    Run Prisma migrations
	@echo   make health     Check API health and AI provider switch
	@echo   make run        Run Flutter on IQOO with hot reload
	@echo DOCKER
	@echo   make build      Build API/admin images
	@echo   make build-nc   No-cache rebuild API/admin
	@echo   make up         Start dev stack on localhost ports
	@echo   make up-full    Start dev stack plus Caddy
	@echo   make down       Stop containers
	@echo   make restart    Restart containers
	@echo   make ps         Show containers
	@echo   make logs       Tail logs
	@echo ORACLE PRODUCTION
	@echo   bash scripts/oracle-prod-env.sh ORACLE_PUBLIC_IP=$(ORACLE_IP)
	@echo   make prod-up
	@echo   make prod-migrate
	@echo   make prod-health ORACLE_IP=$(ORACLE_IP)
	@echo FLUTTER PHONE
	@echo   make devices    List Flutter devices
	@echo   make run        Run on IQOO device id $(DEVICE_ID)
	@echo   make run DEVICE_ID=your_device_id
	@echo   make apk        Build debug APK
	@echo   make release-apk Build private release APKs split per ABI
	@echo   make release-apk API_BASE_URL=https://api.example.com/api/v1
	@echo   make release-oracle ORACLE_IP=$(ORACLE_IP)
	@echo CHECKS
	@echo   make checks     Run Flutter, API, and admin checks

env:
	@$(PS) env

env-check:
	@$(PS) env-check

hash:
	@$(PS) hash -AdminPassword "$(ADMIN_PASSWORD)"

doctor:
	@$(PS) doctor

build:
	$(COMPOSE) build api admin

build-nc:
	$(COMPOSE) build --no-cache api admin

up:
	$(COMPOSE) up -d postgres redis api admin

up-full:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f api admin postgres redis

migrate:
	$(COMPOSE) run --rm --no-deps api npx prisma migrate deploy

health:
	@powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'API health:'; Invoke-RestMethod http://localhost:3000/api/v1/health | ConvertTo-Json; Write-Host 'AI provider:'; Invoke-RestMethod http://localhost:3000/api/v1/ai/providers | ConvertTo-Json -Depth 5"

prod-build:
	$(COMPOSE_PROD) build api admin

prod-up:
	$(COMPOSE_PROD) up -d --build

prod-down:
	$(COMPOSE_PROD) down

prod-restart:
	$(COMPOSE_PROD) restart

prod-ps:
	$(COMPOSE_PROD) ps

prod-logs:
	$(COMPOSE_PROD) logs -f api admin caddy postgres redis

prod-migrate:
	$(COMPOSE_PROD) run --rm --no-deps api npx prisma migrate deploy

prod-health:
	curl -fsS $(ORACLE_API_BASE_URL)/health
	curl -fsS $(ORACLE_API_BASE_URL)/ai/providers

devices:
	cd kajupilot && flutter.bat devices

run:
	@$(PS) flutter-phone -DeviceId "$(DEVICE_ID)"

phone: run

apk:
	cd kajupilot && flutter.bat build apk --debug

release-apk:
	cd kajupilot && flutter.bat build apk --release --split-per-abi --dart-define=API_BASE_URL=$(API_BASE_URL)

release: release-apk

release-oracle:
	$(MAKE) release-apk API_BASE_URL=$(ORACLE_API_BASE_URL)

api-build:
	cd kajupilot-api && npm.cmd run build

api-test:
	cd kajupilot-api && npm.cmd test

api-audit:
	cd kajupilot-api && npm.cmd audit

admin-build:
	cd kajupilot-admin && npm.cmd run build

admin-audit:
	cd kajupilot-admin && npm.cmd audit

checks:
	cd kajupilot && dart.bat format lib test
	cd kajupilot && flutter.bat analyze
	cd kajupilot && flutter.bat test
	cd kajupilot-api && npm.cmd run build
	cd kajupilot-api && npm.cmd test
	cd kajupilot-api && npm.cmd audit
	cd kajupilot-admin && npm.cmd run build
	cd kajupilot-admin && npm.cmd audit
