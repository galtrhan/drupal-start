#!/bin/bash

# Configuration
PROJECT_NAME="drupal"
DOMAIN="${PROJECT_NAME}.local"
CERTS_DIR="./certs"

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function setup_hosts() {
    if ! grep -q "$DOMAIN" /etc/hosts; then
        echo -e "${GREEN}Adding $DOMAIN to /etc/hosts...${NC}"
        echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
    else
        echo -e "${GREEN}$DOMAIN already in /etc/hosts.${NC}"
    fi
}

function setup_certs() {
    if [ ! -f "$CERTS_DIR/drupal.local.pem" ]; then
        echo -e "${GREEN}Generating certificates with mkcert for $DOMAIN...${NC}"
        mkdir -p "$CERTS_DIR"
        # Ensure mkcert is installed in the local trust store
        mkcert -install
        mkcert -cert-file "$CERTS_DIR/drupal.local.pem" -key-file "$CERTS_DIR/drupal.local-key.pem" "$DOMAIN"
    else
         echo -e "${GREEN}Certificates for $DOMAIN already exist.${NC}"
    fi
}

case "$1" in
    start)
        setup_hosts
        setup_certs
        echo -e "${GREEN}Starting site...${NC}"
        docker compose up -d
        echo -e "${GREEN}Site is available at https://$DOMAIN${NC}"
        ;;
    stop)
        echo -e "${GREEN}Stopping site...${NC}"
        docker compose down
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
