#!/bin/bash

# Script to pull SSL certificates from Porkbun API and place them in a specified directory
# Usage: ./porkbun_cert_renewal.sh /path/to/config.json
# run as root

set -e

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# Check if config file is provided
if [ $# -ne 1 ]; then
    log "Usage: $0 /path/to/config.json"
    exit 1
fi

CONFIG_FILE="$1"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    log "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Check if jq is installed (needed for JSON parsing)
if ! command -v jq &> /dev/null; then
    log "Error: 'jq' is required but not installed. Please install it first."
    exit 1
fi

# Read configuration
DOMAIN=$(jq -r '.domain' "$CONFIG_FILE")
CERT_DIR=$(jq -r '.certificate_directory' "$CONFIG_FILE")
API_KEY=$(jq -r '.api_key' "$CONFIG_FILE")
SECRET_KEY=$(jq -r '.secret_key' "$CONFIG_FILE")

# Validate configuration
if [ -z "$DOMAIN" ] || [ -z "$CERT_DIR" ] || [ -z "$API_KEY" ] || [ -z "$SECRET_KEY" ]; then
    log "Error: Missing required configuration parameters"
    log "Please ensure config file contains domain, certificate_directory, api_key, and secret_key"
    exit 1
fi

# Create certificate directory if it doesn't exist
mkdir -p "$CERT_DIR"

log "Starting certificate renewal for $DOMAIN"

# Make API request to retrieve SSL certificate
API_RESPONSE=$(curl -s -X POST "https://api.porkbun.com/api/json/v3/ssl/retrieve/$DOMAIN" \
    -H "Content-Type: application/json" \
    -d '{
        "apikey": "'"$API_KEY"'",
        "secretapikey": "'"$SECRET_KEY"'"
    }')

# Check if API request was successful
STATUS=$(echo "$API_RESPONSE" | jq -r '.status')
if [ "$STATUS" != "SUCCESS" ]; then
    ERROR=$(echo "$API_RESPONSE" | jq -r '.message')
    log "Error: Failed to retrieve certificate: $ERROR"
    exit 1
fi

# Extract certificate and key
CERTIFICATE=$(echo "$API_RESPONSE" | jq -r '.certificatechain')
PRIVATE_KEY=$(echo "$API_RESPONSE" | jq -r '.privatekey')

CERT_DESTINATION="$CERT_DIR/$DOMAIN.cert.pem"
KEY_DESTINATION="$CERT_DIR/$DOMAIN.key.pem"

# Save certificate and private key to files
echo "$CERTIFICATE" > "$CERT_DESTINATION"
echo "$PRIVATE_KEY" > "$KEY_DESTINATION"

# Set proper permissions
chmod 644 "$CERT_DESTINATION"
chmod 600 "$KEY_DESTINATION"

log "Successfully renewed SSL certificate for $DOMAIN"
log "Certificate saved to: $CERT_DESTINATION"
log "Private key saved to: $KEY_DESTINATION"

# Check if we need to reload Nginx
NGINX_CONFIG=$(jq -r '.reload_nginx // "false"' "$CONFIG_FILE")
if [ "$NGINX_CONFIG" = "true" ]; then
    log "Reloading Nginx configuration..."
    NGINX_BIN=$(command -v nginx 2>/dev/null || echo /usr/sbin/nginx)
    if [ -x "$NGINX_BIN" ]; then
        "$NGINX_BIN" -t && "$NGINX_BIN" -s reload
        log "Nginx reloaded successfully"
    else
        log "Warning: Nginx not found, skipping reload"
    fi
fi

exit 0
