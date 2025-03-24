#!/bin/bash

# Run tests for the finance service
pytest services/finance_service/

# Run tests for main service
docker build -t main-service -f ./services/main_service/Dockerfile ./services/main_service
docker build -t finance-service -f ./services/finance_service/Dockerfile ./services/finance_service

docker-compose -f docker-compose.test.yml up -d
docker-compose logs --tail=1000 -f main-service
docker-compose down