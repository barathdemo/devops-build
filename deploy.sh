#!/bin/bash

# Usage: ./deploy.sh <branch>
# Example: ./deploy.sh dev

BRANCH=$1

if [ "$BRANCH" == "dev" ]; then
  COMPOSE_FILE="docker-compose.dev.yml"
  PORT="8081"
elif [ "$BRANCH" == "master" ]; then
  COMPOSE_FILE="docker-compose.prod.yml"
  PORT="8082"
else
  echo "Unsupported branch: $BRANCH"
  exit 1
fi

echo "Cleaning up containers on port $PORT..."

CONTAINER_ID=$(docker ps -q --filter "publish=$PORT")
if [ ! -z "$CONTAINER_ID" ]; then
  docker stop $CONTAINER_ID
  docker rm $CONTAINER_ID
else
  echo "No container found on port $PORT"
fi

echo "Deploying with $COMPOSE_FILE..."
docker-compose -f "$COMPOSE_FILE" up -d

echo "Deployment complete. Running containers:"
docker ps
