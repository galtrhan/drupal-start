#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

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
    docker compose run --rm php sh -c "composer create-project drupal/recommended-project /tmp/drupal && cp -rn /tmp/drupal/. /var/www/html/ && rm -rf /tmp/drupal"
    
    echo -e "${GREEN}Installing Drush...${NC}"
    docker compose run --rm php composer require drush/drush
else
    echo -e "${GREEN}Drupal project already initialized (web/index.php exists).${NC}"
fi

echo -e ""
echo -e "${GREEN}Setup complete!${NC}"
echo -e "You can now start the environment with: ${GREEN}./site.sh start${NC}"
