#!/bin/bash

cd /cloud_service_production/

certbot renew

docker-compose down

docker-compose up -d
