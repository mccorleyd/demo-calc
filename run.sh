#!/bin/bash

docker build -t main-service -f ./services/main_service/Dockerfile ./services/main_service
docker build -t finance-service -f ./services/finance_service/Dockerfile ./services/finance_service

docker-compose down
docker-compose up