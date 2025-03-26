#!/bin/bash

# Exit on any error
set -e

# Load environment variables if they exist
if [ -f .env ]; then
    source .env
fi

# Set default values if not provided
VERSION=${VERSION:-"latest"}

# Pull the latest images
docker-compose -f docker-compose.prod.yml pull

# Stop and remove existing containers
docker-compose -f docker-compose.prod.yml down

# Start new containers
docker-compose -f docker-compose.prod.yml up -d

# Clean up old images
docker image prune -f

# Check if services are healthy
echo "Waiting for services to start..."
sleep 10

# Check main service
if curl -f http://localhost/calculate_mortgage_affordability -X POST \
    -H "Content-Type: application/json" \
    -d '{"annualIncome": 60000, "monthlyExpenses": 1800, "depositAmount": 25000, "mortgageTermYears": 20}' > /dev/null 2>&1; then
    echo "Main service is running"
else
    echo "Main service failed to start"
    docker-compose -f docker-compose.prod.yml logs
    exit 1
fi

echo "Deployment successful!" 