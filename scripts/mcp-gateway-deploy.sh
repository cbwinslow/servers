#!/bin/bash
# Deploy MCP servers to an MCP gateway
# Usage: ./mcp-gateway-deploy.sh [--config FILE] [--gateway-url URL]

set -e

# Default values
CONFIG_FILE="mcp-gateway-config.json"
GATEWAY_URL="${GATEWAY_URL:-http://localhost:8080}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --config|-c)
      CONFIG_FILE="$2"
      shift 2
      ;;
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
NC='\033[0m'

echo -e "${GREEN}Deploying MCP Servers to Gateway${NC}"
echo "Gateway URL: $GATEWAY_URL"
echo "Config file: $CONFIG_FILE"
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "${RED}Error: Configuration file not found: $CONFIG_FILE${NC}"
  echo "Run ./mcp-gateway-config.sh to generate one."
  exit 1
fi

# Check if gateway is reachable
if ! curl -f -s -o /dev/null "$GATEWAY_URL/health" 2>/dev/null; then
  echo -e "${YELLOW}Warning: Gateway health check failed at $GATEWAY_URL/health${NC}"
  echo "Make sure your MCP gateway is running and accessible."
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Deploy configuration to gateway
echo "Deploying configuration..."

# This is a template - adjust the API endpoint based on your gateway implementation
# Common patterns:
# - POST /api/servers/register
# - PUT /api/config
# - POST /api/deploy

DEPLOY_ENDPOINT="$GATEWAY_URL/api/servers/deploy"

if curl -X POST \
  -H "Content-Type: application/json" \
  -d @"$CONFIG_FILE" \
  -f -s -o /tmp/deploy-response.json \
  "$DEPLOY_ENDPOINT"; then
  
  echo -e "${GREEN}✓ Configuration deployed successfully!${NC}"
  echo ""
  echo "Response:"
  cat /tmp/deploy-response.json | jq '.' 2>/dev/null || cat /tmp/deploy-response.json
  echo ""
  
  # Verify deployment
  echo "Verifying deployment..."
  if curl -f -s -o /tmp/status.json "$GATEWAY_URL/api/servers/status"; then
    echo -e "${GREEN}✓ Verification successful${NC}"
    echo ""
    echo "Active servers:"
    cat /tmp/status.json | jq '.servers[] | select(.enabled == true) | .name' 2>/dev/null || echo "Unable to parse response"
  fi
else
  echo -e "${RED}✗ Deployment failed${NC}"
  echo "Response:"
  cat /tmp/deploy-response.json 2>/dev/null || echo "No response received"
  exit 1
fi

echo ""
echo -e "${GREEN}Deployment complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Test server connectivity: ./mcp-gateway-health.sh"
echo "2. Monitor server status: watch -n 5 ./mcp-gateway-health.sh"
echo "3. View gateway logs for any issues"
