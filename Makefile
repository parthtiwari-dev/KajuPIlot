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
        run phone devices apk \
        api-build api-test api-audit admin-build admin-audit checks

DEVICE_ID ?= 1592533185000B8
ADMIN_PASSWORD ?= kaju_admin_dev_password
COMPOSE = docker compose --env-file .env -f docker-compose.yml -f docker-compose.dev.yml
PS = powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1

help:
	@echo KajuPilot dev commands
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
	@echo FLUTTER PHONE
	@echo   make devices    List Flutter devices
	@echo   make run        Run on IQOO device id $(DEVICE_ID)
	@echo   make run DEVICE_ID=your_device_id
	@echo   make apk        Build debug APK
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

devices:
	cd kajupilot && flutter.bat devices

run:
	@$(PS) flutter-phone -DeviceId "$(DEVICE_ID)"

phone: run

apk:
	cd kajupilot && flutter.bat build apk --debug

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
