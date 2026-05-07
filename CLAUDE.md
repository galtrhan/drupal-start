# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Docker-based local development environment boilerplate for Drupal 11, using PHP-FPM (8.3-alpine), Nginx, and PostgreSQL. It is a starter/template repo — the actual Drupal codebase (`web/`, `vendor/`, `composer.json`) is generated during setup and is not committed to git.

## Key Scripts

### `./site` — environment lifecycle manager
- `./site setup` — creates `.env` interactively from `.env.template`, builds images, runs `composer create-project drupal/recommended-project`, installs Drush, sets up `settings.php` and `services.yml`
- `./site start` — checks ports 80/443, adds `$PROJECT_NAME.local` to `/etc/hosts`, generates wildcard mkcert SSL certs in `certs/`, starts containers
- `./site stop` / `./site restart` — wraps `docker compose down` / down+up
- `./site reset` — **destructive**: removes `.env`, `certs/`, `web/`, `vendor/`, `composer.*`, and Docker volumes; reverts to clean boilerplate

### `./drush` — Drush proxy
Runs `docker compose exec php vendor/bin/drush "$@"`. Requires the PHP container to be running.

## Architecture

Three containers orchestrated by `docker-compose.yml`:
- **postgres** (`${PROJECT_NAME}_postgres`) — PostgreSQL, data persisted in `postgres_data` named volume
- **php** (`${PROJECT_NAME}_php`) — custom image (PHP 8.3-FPM + pdo_pgsql, gd, zip, bcmath, intl, opcache + Composer); mounts repo root to `/var/www/html`; receives DB credentials as env vars
- **nginx** (`${PROJECT_NAME}_nginx`) — nginx:alpine; mounts repo root and `nginx.conf.template` (processed via nginx envsubst); terminates SSL with wildcard certs from `certs/`

Nginx proxies PHP via FastCGI to `php:9000`. All HTTP redirects to HTTPS. The Drupal webroot is `web/` inside the container at `/var/www/html/web`.

## Environment Configuration

Copy `.env.template` to `.env` (done automatically by `./site setup`). Key variables:
- `PROJECT_NAME` — sets container names and the local domain (`$PROJECT_NAME.local`)
- `COMPOSE_PROJECT_NAME` — Docker Compose project namespace (defaults to `${PROJECT_NAME}`)
- `DB_HOST=postgres`, `DB_NAME=drupal_db`, `DB_USER=drupal_user`, `DB_PASSWORD`

## Common Commands

```bash
# Shell into PHP container
docker compose exec php bash

# Install a Drupal module
docker compose exec php composer require drupal/[module_name]

# PostgreSQL shell
docker compose exec postgres psql -U drupal_user -d drupal_db

# Clear Drupal caches
./drush cr
```

## Drupal Installation

After `./site start`, visit `https://drupal.local` (or `https://$PROJECT_NAME.local`). Use host `postgres` (not `localhost`) for the database host in the Drupal installer.

## What Is and Is Not Committed

Committed: `site`, `drush`, `Dockerfile`, `docker-compose.yml`, `nginx.conf.template`, `.env.template`, `.gitignore`

Not committed (generated or secret): `web/`, `vendor/`, `composer.json`, `composer.lock`, `.env`, `certs/`, `web/sites/*/settings.php`, `web/sites/*/files/`
