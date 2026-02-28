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
    
    # 0. Get Domain info from .env
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    PROJECT_NAME=${PROJECT_NAME:-"drupal"}
    DOMAIN="${PROJECT_NAME}.local"

    # 1. Stop containers and remove volumes
    echo -e "${GREEN}Stopping project containers...${NC}"
    docker compose down -v || true
    
    # 1.5 Check for port conflicts and offer to stop all containers
    for port in 80 443; do
        if sudo lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
            echo -e "${RED}Warning: Something is still using port $port.${NC}"
            read -p "Would you like to stop ALL running docker containers to free up ports? (y/N) " stop_all
            if [[ $stop_all == [yY] ]]; then
                docker stop $(docker ps -q) || true
            fi
            break
        fi
    done
    
    # 2. Remove host entry
    if grep -q "$DOMAIN" /etc/hosts; then
        echo -e "${GREEN}Removing $DOMAIN from /etc/hosts...${NC}"
        sudo sed -i "/$DOMAIN/d" /etc/hosts
    fi

    # 3. Remove runtime files
    # We use sudo for vendor/ and web/ because Docker often creates files as root
    sudo rm -rf .env certs/ web/ vendor/ recipes/ composer.json composer.lock .editorconfig .gitattributes LICENSE.txt
    
    echo -e "${GREEN}Cleanup complete! Project is back to clean boilerplate state.${NC}"
else
    echo -e "Cleanup cancelled."
fi
