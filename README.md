# Drupal Local Development Environment

This project provides a Docker-based local development environment for Drupal 11 using PHP-FPM, Nginx, and PostgreSQL.

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [mkcert](https://github.com/FiloSottile/mkcert) (for local HTTPS trust)

## Setup Guide

### 1. Initial Installation
Run the following script to create your `.env` file (interactively), build Docker images, and download Drupal:
```bash
./setup.sh
```

### 2. Start Services
Use the management script to handle `/etc/hosts` updates, HTTPS certificates, and start the containers:
```bash
./site.sh start
```
*Note: This will prompt for your sudo password to update `/etc/hosts`.*

### 3. Drupal Installation
- Open [https://drupal.local](https://drupal.local)
- **Database Settings (PostgreSQL):**
  - **Database name:** `drupal_db` (or as set in .env)
  - **Database username:** `drupal_user`
  - **Database password:** `verystrongpassword` (or as set in .env)
  - **Host:** `postgres`

## Maintenance

### Management Script (site.sh)
The `site.sh` script provides easy management of the containers and local configuration:

- `./site.sh start`: Verifies ports 80/443, updates `/etc/hosts`, generates SSL certs, and starts containers.
- `./site.sh stop`: Stops and removes all containers for the project.
- `./site.sh restart`: Stops and then starts the environment again.

### Cleanup / Reset
If you want to reset the project back to the clean boilerplate state (removes all Drupal files, database, and certs):
```bash
./reset.sh
```

## Common Tasks

### Shell Access
To enter the PHP container and run commands directly:
```bash
docker exec -it ${PROJECT_NAME}_php bash
```
*(Alternatively, you can use `docker compose exec php bash`)*

### Using Drush
Drush is installed as a Composer dependency. You can run it easily using the helper script:
```bash
./drush.sh [command]
```
Example: Clear all caches:
```bash
./drush.sh cr
```

### Using Composer
Install new modules or dependencies:
```bash
docker compose exec php composer require drupal/[module_name]
```

### Database Management
To enter the PostgreSQL shell:
```bash
docker compose exec postgres psql -U drupal_user -d drupal_db
```

## Project Structure
- `web/`: Drupal root (index.php, themes, modules).
- `vendor/`: Composer-managed dependencies and Drush.
- `nginx.conf.template`: Template for Nginx server configuration.
- `Dockerfile`: Custom PHP image definition.
- `docker-compose.yml`: Service orchestration.
