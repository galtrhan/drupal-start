#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 0. Check permissions
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: Please do not run this script as root/sudo.${NC}"
    echo "Composer and mkcert should be run as your regular user."
    exit 1
fi

# Ensure current directory is owned by the current user
CURRENT_OWNER=$(stat -c '%U' .)
if [ "$CURRENT_OWNER" == "root" ]; then
    echo -e "${GREEN}Fixing directory ownership...${NC}"
    sudo chown -R $(whoami):$(id -gn) .
fi

echo -e "${GREEN}Starting Drupal Local Environment Setup...${NC}"

# 1. Initialize .env if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${GREEN}Creating .env from .env.template...${NC}"
    cp .env.template .env
else
    echo -e "${GREEN}.env file already exists.${NC}"
fi

# 2. Build Docker images
echo -e "${GREEN}Building Docker images...${NC}"
docker compose build

# 3. Initialize Drupal project if web/index.php doesn't exist
if [ ! -f web/index.php ]; then
    echo -e "${GREEN}Initializing Drupal project with Composer...${NC}"
    # Remove any existing partial installation files to ensure a clean start
    sudo rm -rf /tmp/drupal_init
    docker compose run --rm php sh -c "git config --global --add safe.directory /var/www/html && composer create-project drupal/recommended-project /tmp/drupal_init --no-interaction && cp -a /tmp/drupal_init/. /var/www/html/ && rm -rf /tmp/drupal_init"
    
    echo -e "${GREEN}Installing Drush...${NC}"
    docker compose run --rm php composer require drush/drush --no-interaction
else
    echo -e "${GREEN}Drupal project already initialized (web/index.php exists).${NC}"
fi

# 4. Fix permissions and create required directories
echo -e "${GREEN}Setting up Drupal files directory and permissions...${NC}"
mkdir -p web/sites/default/files/translations
chmod -R 777 web/sites/default/files

if [ ! -f web/sites/default/settings.php ]; then
    echo -e "${GREEN}Creating settings.php...${NC}"
    cp web/sites/default/default.settings.php web/sites/default/settings.php
    chmod 666 web/sites/default/settings.php
fi

if [ ! -f web/sites/default/services.yml ]; then
    echo -e "${GREEN}Creating services.yml...${NC}"
    cp web/sites/default/default.services.yml web/sites/default/services.yml
    chmod 666 web/sites/default/services.yml
fi

echo -e ""
echo -e "${GREEN}Setup complete!${NC}"
echo -e "You can now start the environment with: ${GREEN}./site.sh start${NC}"
