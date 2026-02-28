# Drupal Local Development Environment

This project provides a Docker-based local development environment for Drupal 11 using PHP-FPM, Nginx, and PostgreSQL.

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [mkcert](https://github.com/FiloSottile/mkcert) (for local HTTPS trust)

## Setup Guide

### 1. Configuration (.env)
Copy the template and set your project name:
```bash
cp .env.template .env
```
Default `PROJECT_NAME=drupal` will set your local domain to `drupal.local`.

### 2. Initial Installation
Run the following script to create your `.env` file, build Docker images, and download Drupal:
```bash
./setup.sh
```

### 3. Start Services
Use the provided management script to handle `/etc/hosts` updates and HTTPS certificates:
```bash
./site.sh start
```
*Note: This will prompt for your sudo password to update `/etc/hosts`.*

### 4. Drupal Installation
- Open [https://drupal.local](https://drupal.local)
- **Database Settings (PostgreSQL):**
  - **Database name:** `drupal_db` (or as set in .env)
  - **Database username:** `drupal_user`
  - **Database password:** `drupal_password`
  - **Host:** `postgres`

## Maintenance

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
docker compose exec postgres psql -U drupal_user -d drupal
```

## Project Structure
- `web/`: Drupal root (index.php, themes, modules).
- `vendor/`: Composer-managed dependencies and Drush.
- `nginx.conf`: Nginx server configuration.
- `Dockerfile`: Custom PHP image definition.
- `docker-compose.yml`: Service orchestration.

## Permissions Note
If you encounter permission issues in the web interface, run:
```bash
docker compose exec php sh -c "chmod -R 777 web/sites/default/files"
```
