#!/bin/bash

# Build the services
docker-compose build

# Run tests for the finance service
docker-compose run finance-service pytest

# Run tests for main service
docker-compose run main-service pytest

# Clean up
docker-compose down