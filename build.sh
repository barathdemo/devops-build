#!/bin/bash

# Usage: ./build.sh <branch> <build_number>
# Example: ./build.sh dev 42

BRANCH=$1
BUILD_NUMBER=$2

DEV_IMAGE="barath2707/dev"
PROD_IMAGE="barath2707/prod"

if [ "$BRANCH" == "dev" ]; then
  IMAGE=$DEV_IMAGE
  COMPOSE_FILE="docker-compose.dev.yml"
elif [ "$BRANCH" == "master" ]; then
  IMAGE=$PROD_IMAGE
  COMPOSE_FILE="docker-compose.prod.yml"
else
  echo "Unsupported branch: $BRANCH"
  exit 1
fi

echo "Using Compose File: $COMPOSE_FILE"
echo "Building Docker image for $BRANCH..."

# Build the image
docker-compose -f "$COMPOSE_FILE" build

# Tag the image
docker tag "$IMAGE" "${IMAGE}:${BUILD_NUMBER}"

# Push the image
docker push "${IMAGE}:${BUILD_NUMBER}"

echo "Build and push complete for $IMAGE:$BUILD_NUMBER"
