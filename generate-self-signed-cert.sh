#!/bin/bash

# This script generates self-signed certificates for development purposes
# For production, use Let's Encrypt certificates instead

# Create directory for SSL certificates
mkdir -p ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/privkey.pem \
  -out ssl/fullchain.pem \
  -subj "/CN=mortgage.yourdomain.com" \
  -addext "subjectAltName = DNS:mortgage.yourdomain.com,DNS:www.mortgage.yourdomain.com,IP:139.162.198.94"

# Set proper permissions
chmod 600 ssl/privkey.pem
chmod 644 ssl/fullchain.pem

echo "Self-signed certificates generated in the ./ssl directory"
echo "NOTE: These are for development only. For production, use Let's Encrypt." 