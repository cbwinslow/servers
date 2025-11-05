#!/bin/bash
# Push MCP server Docker images to Docker Hub
# Usage: ./docker-push-dockerhub.sh [SERVER_NAME]

set -e

# Configuration
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-cbwinslow}"
DOCKERHUB_REGISTRY="docker.io/${DOCKERHUB_USERNAME}"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Pushing MCP Servers to Docker Hub${NC}"
echo "Username: $DOCKERHUB_USERNAME"
echo ""

# Check if Docker is logged in
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker is not running"
  exit 1
fi

# Login to Docker Hub if credentials are provided
if [ -n "$DOCKERHUB_TOKEN" ]; then
  echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin docker.io
elif [ -n "$DOCKERHUB_PASSWORD" ]; then
  echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin docker.io
else
  echo -e "${YELLOW}Note: DOCKERHUB_TOKEN or DOCKERHUB_PASSWORD not set${NC}"
  echo -e "${YELLOW}Assuming you're already logged in to Docker Hub${NC}"
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# If a specific server is provided, build and push only that
if [ -n "$1" ]; then
  SERVERS=("$1")
else
  SERVERS=(
    "everything"
    "fetch"
    "filesystem"
    "git"
    "memory"
    "sequentialthinking"
    "time"
  )
fi

# Build and push each server
for server in "${SERVERS[@]}"; do
  echo -e "${GREEN}Processing $server...${NC}"
  
  IMAGE_NAME="${DOCKERHUB_REGISTRY}/mcp-server-${server}"
  
  # Tag with both latest and dated version
  VERSION_TAG="$(date +%Y%m%d)"
  
  docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${VERSION_TAG}" || true
  
  # Push both tags
  docker push "${IMAGE_NAME}:latest"
  docker push "${IMAGE_NAME}:${VERSION_TAG}"
  
  echo -e "${GREEN}✓ Pushed ${IMAGE_NAME}:latest and ${IMAGE_NAME}:${VERSION_TAG}${NC}"
  echo ""
done

echo -e "${GREEN}All images pushed to Docker Hub successfully!${NC}"
