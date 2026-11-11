# Drupal local development environment

A local Drupal 11 stack with Docker, Nginx, PHP-FPM and PostgreSQL. Use it for module and theme development.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
- [mkcert](https://github.com/FiloSottile/mkcert), for local HTTPS certificates

## Setup

1. Create your `.env`, build the Docker images and download Drupal:

```bash
./site setup
```

2. Start the containers, update `/etc/hosts` and generate the HTTPS certificates:

```bash
./site start
```

The script asks for your sudo password to edit `/etc/hosts`.

3. Open https://drupal.local and run the Drupal installer. Database settings:

| Setting | Value |
| --- | --- |
| Name | `drupal_db`, or your `.env` value |
| User | `drupal_user` |
| Password | `verystrongpassword`, or your `.env` value |
| Host | `postgres` |

## Management script

| Command | What it does |
| --- | --- |
| `./site setup` | Creates `.env` interactively, builds the images, initializes Drupal. |
| `./site start` | Checks ports 80/443, updates `/etc/hosts`, generates SSL certificates, starts the containers. |
| `./site stop` | Stops and removes the project containers. |
| `./site restart` | Stops, then starts the environment again. |
| `./site reset` | **Warning:** removes everything and resets to the clean boilerplate. |

## Common tasks

Enter the PHP container and run commands directly:

```bash
docker compose exec php bash
```

Run Drush, installed as a Composer dependency, through the helper script. To clear all caches:

```bash
./drush cr
```

Install a module with Composer:

```bash
docker compose exec php composer require drupal/[module_name]
```

Open the PostgreSQL shell:

```bash
docker compose exec postgres psql -U drupal_user -d drupal_db
```

## Project structure

- `web/`, the Drupal root with `index.php`, themes and modules
- `vendor/`, Composer dependencies and Drush
- `nginx.conf.template`, the Nginx server configuration template
- `Dockerfile`, the PHP image
- `docker-compose.yml`, service orchestration
