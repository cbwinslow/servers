#!/bin/bash
# Push MCP server Docker images to GitHub Container Registry (GHCR)
# Usage: ./docker-push-ghcr.sh [SERVER_NAME]

set -e

# Configuration
GITHUB_USERNAME="${GITHUB_USERNAME:-cbwinslow}"
GHCR_REGISTRY="ghcr.io/${GITHUB_USERNAME}"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Pushing MCP Servers to GitHub Container Registry${NC}"
echo "Username: $GITHUB_USERNAME"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker is not running"
  exit 1
fi

# Login to GHCR if token is provided
if [ -n "$GITHUB_TOKEN" ]; then
  echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin
else
  echo -e "${YELLOW}Note: GITHUB_TOKEN not set${NC}"
  echo -e "${YELLOW}Assuming you're already logged in to GHCR${NC}"
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
  
  IMAGE_NAME="${GHCR_REGISTRY}/mcp-server-${server}"
  
  # Tag with both latest and dated version
  VERSION_TAG="$(date +%Y%m%d)"
  
  docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${VERSION_TAG}" || true
  
  # Push both tags
  docker push "${IMAGE_NAME}:latest"
  docker push "${IMAGE_NAME}:${VERSION_TAG}"
  
  echo -e "${GREEN}✓ Pushed ${IMAGE_NAME}:latest and ${IMAGE_NAME}:${VERSION_TAG}${NC}"
  echo ""
done

echo -e "${GREEN}All images pushed to GitHub Container Registry successfully!${NC}"
