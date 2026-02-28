#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${RED}Danger: This will remove all Drupal files, database, and local certificates to reset the boilerplate.${NC}"
read -p "Are you sure you want to continue? (y/N) " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    echo -e "${GREEN}Cleaning up environment...${NC}"
    
    # 1. Stop containers and remove volumes
    docker compose down -v || true
    
    # 2. Remove runtime files
    # We use sudo for vendor/ and web/ because Docker often creates files as root
    sudo rm -rf .env certs/ web/ vendor/ composer.json composer.lock .editorconfig .gitattributes LICENSE.txt
    
    echo -e "${GREEN}Cleanup complete! Project is back to clean boilerplate state.${NC}"
else
    echo -e "Cleanup cancelled."
fi
