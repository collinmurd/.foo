#!/bin/bash

# Script to pull SSL certificates from Porkbun API and place them in a specified directory
# Usage: ./porkbun_cert_renewal.sh /path/to/config.json
# run as root

set -e

# Check if config file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 /path/to/config.json"
    exit 1
fi

CONFIG_FILE="$1"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Check if jq is installed (needed for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is required but not installed. Please install it first."
    exit 1
fi

# Read configuration
DOMAIN=$(jq -r '.domain' "$CONFIG_FILE")
CERT_DIR=$(jq -r '.certificate_directory' "$CONFIG_FILE")
API_KEY=$(jq -r '.api_key' "$CONFIG_FILE")
SECRET_KEY=$(jq -r '.secret_key' "$CONFIG_FILE")

# Validate configuration
if [ -z "$DOMAIN" ] || [ -z "$CERT_DIR" ] || [ -z "$API_KEY" ] || [ -z "$SECRET_KEY" ]; then
    echo "Error: Missing required configuration parameters"
    echo "Please ensure config file contains domain, certificate_directory, api_key, and secret_key"
    exit 1
fi

# Create certificate directory if it doesn't exist
mkdir -p "$CERT_DIR"

echo "Starting certificate renewal for $DOMAIN"

# Make API request to retrieve SSL certificate
API_RESPONSE=$(curl -s -X POST "https://porkbun.com/api/json/v3/ssl/retrieve/$DOMAIN" \
    -H "Content-Type: application/json" \
    -d '{
        "apikey": "'"$API_KEY"'",
        "secretapikey": "'"$SECRET_KEY"'"
    }')

# Check if API request was successful
STATUS=$(echo "$API_RESPONSE" | jq -r '.status')
if [ "$STATUS" != "SUCCESS" ]; then
    ERROR=$(echo "$API_RESPONSE" | jq -r '.message')
    echo "Error: Failed to retrieve certificate: $ERROR"
    exit 1
fi

# Extract certificate and key
CERTIFICATE=$(echo "$API_RESPONSE" | jq -r '.certificatechain')
PRIVATE_KEY=$(echo "$API_RESPONSE" | jq -r '.privatekey')

# Save certificate and private key to files
echo "$CERTIFICATE" > "$CERT_DIR/domain.cert.pem"
echo "$PRIVATE_KEY" > "$CERT_DIR/private.key.pem"

# Set proper permissions
chmod 644 "$CERT_DIR/domain.cert.pem"
chmod 600 "$CERT_DIR/private.key.pem"

echo "Successfully renewed SSL certificate for $DOMAIN"
echo "Certificate saved to: $CERT_DIR/domain.cert.pem"
echo "Private key saved to: $CERT_DIR/private.key.pem"

# Check if we need to reload Nginx
NGINX_CONFIG=$(jq -r '.reload_nginx // "false"' "$CONFIG_FILE")
if [ "$NGINX_CONFIG" = "true" ]; then
    echo "Reloading Nginx configuration..."
    if command -v nginx &> /dev/null; then
        nginx -t && systemctl reload nginx
        echo "Nginx reloaded successfully"
    else
        echo "Warning: Nginx not found, skipping reload"
    fi
fi

exit 0
