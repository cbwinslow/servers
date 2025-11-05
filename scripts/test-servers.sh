#!/bin/bash
# Test all MCP servers are working correctly
# Usage: ./test-servers.sh [--mode MODE]

set -e

# Default values
MODE="${1:-docker}"

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           MCP Servers Integration Tests                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test
run_test() {
  local test_name=$1
  local test_command=$2
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  
  echo -n "Testing $test_name... "
  
  if eval "$test_command" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PASSED${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    return 0
  else
    echo -e "${RED}✗ FAILED${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    return 1
  fi
}

# Docker mode tests
test_docker() {
  echo -e "${YELLOW}Running Docker tests...${NC}"
  echo ""
  
  # Check if docker is running
  run_test "Docker daemon" "docker info"
  
  # Check if images exist
  SERVERS=(
    "everything"
    "fetch"
    "filesystem"
    "git"
    "memory"
    "sequentialthinking"
    "time"
  )
  
  for server in "${SERVERS[@]}"; do
    run_test "Image: mcp-server-$server" \
      "docker images ghcr.io/cbwinslow/mcp-server-$server:latest -q | grep -q ."
  done
  
  # Test Docker Compose
  if [ -f "$ROOT_DIR/docker-compose.yml" ]; then
    run_test "Docker Compose config" \
      "cd $ROOT_DIR && docker-compose config"
  fi
}

# Container tests (if running)
test_containers() {
  echo ""
  echo -e "${YELLOW}Testing running containers...${NC}"
  echo ""
  
  SERVERS=(
    "mcp-everything"
    "mcp-fetch"
    "mcp-filesystem"
    "mcp-git"
    "mcp-memory"
    "mcp-sequentialthinking"
    "mcp-time"
  )
  
  for server in "${SERVERS[@]}"; do
    run_test "Container: $server" \
      "docker ps --filter name=$server --format '{{.Status}}' | grep -q 'Up'"
  done
  
  # Test network
  run_test "MCP network exists" \
    "docker network inspect mcp-network"
}

# Script tests
test_scripts() {
  echo ""
  echo -e "${YELLOW}Testing helper scripts...${NC}"
  echo ""
  
  SCRIPTS=(
    "docker-build-all.sh"
    "docker-push-dockerhub.sh"
    "docker-push-ghcr.sh"
    "mcp-gateway-config.sh"
    "mcp-gateway-deploy.sh"
    "mcp-gateway-health.sh"
    "quick-start.sh"
  )
  
  for script in "${SCRIPTS[@]}"; do
    run_test "Script: $script" \
      "[ -x $SCRIPT_DIR/$script ]"
  done
}

# Documentation tests
test_docs() {
  echo ""
  echo -e "${YELLOW}Testing documentation...${NC}"
  echo ""
  
  run_test "DOCKER_DEPLOYMENT.md exists" \
    "[ -f $ROOT_DIR/DOCKER_DEPLOYMENT.md ]"
  
  run_test ".env.example exists" \
    "[ -f $ROOT_DIR/.env.example ]"
  
  run_test "docker-compose.yml exists" \
    "[ -f $ROOT_DIR/docker-compose.yml ]"
  
  run_test "k8s manifests exist" \
    "[ -d $ROOT_DIR/k8s ] && [ -f $ROOT_DIR/k8s/00-namespace.yaml ]"
}

# Run tests based on mode
case $MODE in
  docker)
    test_docker
    test_scripts
    test_docs
    ;;
  containers)
    test_containers
    ;;
  all)
    test_docker
    test_containers
    test_scripts
    test_docs
    ;;
  *)
    echo -e "${RED}Unknown test mode: $MODE${NC}"
    echo "Available modes: docker, containers, all"
    exit 1
    ;;
esac

# Print summary
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""
printf "Total tests:  %d\n" $TOTAL_TESTS
printf "${GREEN}Passed:       %d${NC}\n" $PASSED_TESTS
printf "${RED}Failed:       %d${NC}\n" $FAILED_TESTS
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ Some tests failed${NC}"
  exit 1
fi
