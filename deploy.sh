#!/bin/bash

# Exit on any error
set -e

# Load environment variables if they exist
if [ -f .env ]; then
    source .env
fi

# Set default values if not provided
VERSION=${VERSION:-"latest"}
DOMAIN="139-162-198-94.ip.linodeusercontent.com"
EMAIL=${EMAIL:-"admin@example.com"}  # Replace with your email for Let's Encrypt notifications
USE_LETSENCRYPT=${USE_LETSENCRYPT:-"true"}

echo "=== Starting deployment with HTTPS for domain: $DOMAIN ==="

# Install certbot if not already installed (for Let's Encrypt)
if [ "$USE_LETSENCRYPT" = "true" ] && ! command -v certbot &> /dev/null; then
    echo "Installing certbot for Let's Encrypt..."
    apt-get update
    apt-get install -y certbot
fi

# Ensure the ssl directory exists
mkdir -p ./ssl

# Stop any existing containers first
if [ -f docker-compose.prod.yml ]; then
    echo "Stopping existing containers..."
    docker-compose -f docker-compose.prod.yml down
fi

# Check SSL certificate strategy
if [ "$USE_LETSENCRYPT" = "true" ]; then
    echo "=== Setting up Let's Encrypt certificates ==="
    
    # Request a certificate from Let's Encrypt
    echo "Requesting certificates from Let's Encrypt..."
    certbot certonly --standalone --non-interactive --agree-tos --email $EMAIL -d $DOMAIN
    
    # Copy certificates to the right location
    echo "Copying certificates to the deployment directory..."
    cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem ./ssl/
    cp /etc/letsencrypt/live/$DOMAIN/privkey.pem ./ssl/
    
    # Set proper permissions
    chmod 644 ./ssl/fullchain.pem
    chmod 600 ./ssl/privkey.pem
    
    # Setup automatic renewal
    echo "Setting up automatic certificate renewal..."
    cat > /root/renew-cert.sh << EOF
#!/bin/bash
certbot renew --quiet

# Only copy if renewal was successful
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
  cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /root/mortgage-calculator/ssl/
  cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /root/mortgage-calculator/ssl/
  chmod 644 /root/mortgage-calculator/ssl/fullchain.pem
  chmod 600 /root/mortgage-calculator/ssl/privkey.pem
  cd /root/mortgage-calculator && docker-compose -f docker-compose.prod.yml restart nginx
fi
EOF
    
    chmod +x /root/renew-cert.sh
    
    # Add to crontab if not already there
    CRON_JOB="0 0,12 * * * /root/renew-cert.sh"
    if ! (crontab -l 2>/dev/null | grep -q "$CRON_JOB"); then
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo "Added certificate renewal to crontab"
    fi
    
else
    echo "=== Generating self-signed certificates ==="
    
    # Generate self-signed certificates if they don't exist
    if [ ! -f "./ssl/fullchain.pem" ] || [ ! -f "./ssl/privkey.pem" ]; then
        echo "Generating self-signed certificates..."
        
        # Generate self-signed certificate
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
          -keyout ./ssl/privkey.pem \
          -out ./ssl/fullchain.pem \
          -subj "/CN=$DOMAIN" \
          -addext "subjectAltName = DNS:$DOMAIN,IP:139.162.198.94" \
          -batch
        
        chmod 600 ./ssl/privkey.pem
        chmod 644 ./ssl/fullchain.pem
        
        echo "Self-signed certificates generated."
    fi
fi

# Pull the latest images
echo "=== Pulling latest Docker images ==="
docker-compose -f docker-compose.prod.yml pull

# Start services
echo "=== Starting services ==="
docker-compose -f docker-compose.prod.yml up -d

# Clean up old images
echo "=== Cleaning up old images ==="
docker image prune -f

# Check if services are healthy
echo "=== Checking service health ==="
echo "Waiting for services to start..."
sleep 15  # Increased wait time to ensure services are fully ready

# Check main service via Nginx
if curl -f -k https://localhost/calculate_mortgage_affordability -X POST \
    -H "Content-Type: application/json" \
    -d '{"annualIncome": 60000, "monthlyExpenses": 1800, "depositAmount": 25000, "mortgageTermYears": 20}' > /dev/null 2>&1; then
    echo "✅ Services are running with HTTPS"
    echo "You can now access your service at: https://$DOMAIN/calculate_mortgage_affordability"
else
    echo "⚠️ Failed to connect via HTTPS, trying HTTP..."
    if curl -f http://localhost/calculate_mortgage_affordability -X POST \
        -H "Content-Type: application/json" \
        -d '{"annualIncome": 60000, "monthlyExpenses": 1800, "depositAmount": 25000, "mortgageTermYears": 20}' > /dev/null 2>&1; then
        echo "✅ Services are running with HTTP"
        echo "You can access your service at: http://$DOMAIN/calculate_mortgage_affordability"
        echo "⚠️ However, HTTPS setup failed. Check Nginx and SSL certificate configuration."
    else
        echo "❌ Services failed to start"
        docker-compose -f docker-compose.prod.yml logs
        exit 1
    fi
fi

echo "=== Deployment completed successfully! ===" 