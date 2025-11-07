#!/bin/bash
# Build all MCP servers as Docker images
# Usage: ./docker-build-all.sh [--push] [--registry REGISTRY]

set -e

# Default values
PUSH=false
REGISTRY="ghcr.io/cbwinslow"
PLATFORM="linux/amd64,linux/arm64"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --push)
      PUSH=true
      shift
      ;;
    --registry)
      REGISTRY="$2"
      shift 2
      ;;
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building MCP Server Docker Images${NC}"
echo "Registry: $REGISTRY"
echo "Platform: $PLATFORM"
echo "Push: $PUSH"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# List of MCP servers to build
SERVERS=(
  "everything"
  "fetch"
  "filesystem"
  "git"
  "memory"
  "sequentialthinking"
  "time"
)

# Build each server
SUCCESS_COUNT=0
FAILED_SERVERS=()

for server in "${SERVERS[@]}"; do
  echo -e "${YELLOW}Building $server...${NC}"
  
  IMAGE_NAME="${REGISTRY}/mcp-server-${server}"
  DOCKERFILE="${ROOT_DIR}/src/${server}/Dockerfile"
  
  if [ ! -f "$DOCKERFILE" ]; then
    echo -e "${RED}Dockerfile not found for $server${NC}"
    FAILED_SERVERS+=("$server (no Dockerfile)")
    continue
  fi
  
  # Build command
  BUILD_CMD="docker buildx build"
  BUILD_CMD="$BUILD_CMD --platform $PLATFORM"
  BUILD_CMD="$BUILD_CMD -t ${IMAGE_NAME}:latest"
  BUILD_CMD="$BUILD_CMD -f ${DOCKERFILE}"
  BUILD_CMD="$BUILD_CMD --build-arg BUILDKIT_INLINE_CACHE=1"
  
  if [ "$PUSH" = true ]; then
    BUILD_CMD="$BUILD_CMD --push"
  else
    BUILD_CMD="$BUILD_CMD --load"
  fi
  
  BUILD_CMD="$BUILD_CMD ${ROOT_DIR}"
  
  if eval $BUILD_CMD; then
    echo -e "${GREEN}✓ Successfully built $server${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    echo -e "${RED}✗ Failed to build $server${NC}"
    FAILED_SERVERS+=("$server")
  fi
  
  echo ""
done

# Summary
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Build Summary${NC}"
echo -e "${GREEN}================================${NC}"
echo "Successfully built: $SUCCESS_COUNT/${#SERVERS[@]}"

if [ ${#FAILED_SERVERS[@]} -gt 0 ]; then
  echo -e "${RED}Failed servers:${NC}"
  for server in "${FAILED_SERVERS[@]}"; do
    echo -e "${RED}  - $server${NC}"
  done
  exit 1
fi

echo -e "${GREEN}All servers built successfully!${NC}"

if [ "$PUSH" = true ]; then
  echo -e "${GREEN}Images pushed to $REGISTRY${NC}"
else
  echo -e "${YELLOW}Images built locally (use --push to push to registry)${NC}"
fi
