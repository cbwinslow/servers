#!/bin/bash
# Health check and monitoring for MCP servers through gateway
# Usage: ./mcp-gateway-health.sh [--gateway-url URL]

set -e

# Default values
GATEWAY_URL="${GATEWAY_URL:-http://localhost:8080}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --gateway-url|-u)
      GATEWAY_URL="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         MCP Gateway Health Check & Monitoring           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Gateway URL: $GATEWAY_URL"
echo "Time: $(date)"
echo ""

# Check gateway health
echo -e "${YELLOW}Checking gateway...${NC}"
if curl -f -s -o /dev/null "$GATEWAY_URL/health" 2>/dev/null; then
  echo -e "${GREEN}✓ Gateway is healthy${NC}"
else
  echo -e "${RED}✗ Gateway is not responding${NC}"
  exit 1
fi

echo ""

# Get server status
echo -e "${YELLOW}Server Status:${NC}"
echo ""

SERVERS=(
  "everything:3000"
  "fetch:3001"
  "filesystem:3002"
  "git:3003"
  "memory:3004"
  "sequentialthinking:3005"
  "time:3006"
)

printf "%-25s %-10s %-15s\n" "Server" "Status" "Response Time"
printf "%-25s %-10s %-15s\n" "------" "------" "-------------"

for server_info in "${SERVERS[@]}"; do
  IFS=':' read -r server port <<< "$server_info"
  
  # Check if server is responding
  start_time=$(date +%s%3N)
  
  if timeout 5 bash -c "docker ps --filter name=mcp-$server --format '{{.Status}}' | grep -q 'Up'" 2>/dev/null; then
    status="${GREEN}✓ UP${NC}"
    end_time=$(date +%s%3N)
    response_time=$((end_time - start_time))
    response="${response_time}ms"
  else
    status="${RED}✗ DOWN${NC}"
    response="-"
  fi
  
  printf "%-25s %-20s %-15s\n" "$server" "$(echo -e $status)" "$response"
done

echo ""

# Check Docker containers
echo -e "${YELLOW}Docker Container Status:${NC}"
docker ps --filter "name=mcp-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "No MCP containers running"

echo ""

# Resource usage
echo -e "${YELLOW}Resource Usage:${NC}"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" \
  $(docker ps --filter "name=mcp-" -q) 2>/dev/null || echo "No MCP containers running"

echo ""

# Network connectivity
echo -e "${YELLOW}Network Status:${NC}"
if docker network inspect mcp-network > /dev/null 2>&1; then
  echo -e "${GREEN}✓ MCP network exists${NC}"
  CONTAINER_COUNT=$(docker network inspect mcp-network -f '{{len .Containers}}')
  echo "  Connected containers: $CONTAINER_COUNT"
else
  echo -e "${RED}✗ MCP network not found${NC}"
fi

echo ""

# Volume status
echo -e "${YELLOW}Volume Status:${NC}"
if docker volume inspect mcp-memory-data > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Memory data volume exists${NC}"
  SIZE=$(docker system df -v | grep mcp-memory-data | awk '{print $3}')
  echo "  Size: ${SIZE:-unknown}"
else
  echo -e "${YELLOW}⚠ Memory data volume not found${NC}"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo "Refresh: Run this script again or use 'watch -n 5 $0'"
