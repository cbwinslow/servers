#!/bin/bash
# Example usage scenarios for MCP servers
# This script demonstrates various ways to deploy and use MCP servers

set -e

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        MCP Servers - Usage Examples                     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_example() {
  local title=$1
  local description=$2
  local command=$3
  
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}Example: $title${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
  echo ""
  echo "Description: $description"
  echo ""
  echo "Command:"
  echo -e "${YELLOW}$command${NC}"
  echo ""
  read -p "Press Enter to continue..."
  echo ""
}

echo "This script shows example usage patterns for MCP servers."
echo "Each example demonstrates a different deployment scenario."
echo ""
read -p "Press Enter to start..."
echo ""

# Example 1: Quick Start
show_example \
  "Quick Start - One Command Deployment" \
  "Deploy all MCP servers using Docker Compose with a single command. This is the fastest way to get started." \
  "./scripts/quick-start.sh"

# Example 2: Individual Server
show_example \
  "Run Individual Server" \
  "Run a single MCP server (memory) with Docker, useful for testing or when you only need one server." \
  "docker run -it --rm -v mcp-memory-data:/data ghcr.io/cbwinslow/mcp-server-memory:latest"

# Example 3: Filesystem with Custom Mount
show_example \
  "Filesystem Server with Custom Data" \
  "Run the filesystem server with a custom directory mounted, allowing the server to access specific files." \
  "docker run -it --rm -v \$(pwd)/my-data:/data:ro ghcr.io/cbwinslow/mcp-server-filesystem:latest /data"

# Example 4: Git Server
show_example \
  "Git Server with Repository Access" \
  "Run the git server with access to local git repositories for analysis and operations." \
  "docker run -it --rm -v \$(pwd)/repos:/repos:ro ghcr.io/cbwinslow/mcp-server-git:latest --repository /repos/my-project"

# Example 5: Docker Compose with Custom Config
show_example \
  "Docker Compose with Custom Ports" \
  "Start services using Docker Compose with custom configuration." \
  "docker-compose up -d && docker-compose logs -f"

# Example 6: Building Custom Images
show_example \
  "Build Custom Images" \
  "Build all MCP server images locally with custom registry name." \
  "./scripts/docker-build-all.sh --registry my-registry.com/my-org"

# Example 7: Push to GitHub Container Registry
show_example \
  "Push to GitHub Container Registry" \
  "Build and push all images to GHCR for sharing or deployment." \
  "export GITHUB_USERNAME=your-username
export GITHUB_TOKEN=your-token
./scripts/docker-build-all.sh --push --registry ghcr.io/\$GITHUB_USERNAME"

# Example 8: MCP Gateway Configuration
show_example \
  "Generate MCP Gateway Config" \
  "Create a configuration file for routing requests through an MCP gateway." \
  "./scripts/mcp-gateway-config.sh --output my-gateway-config.json --host gateway.example.com --port 8080"

# Example 9: Deploy to Gateway
show_example \
  "Deploy to MCP Gateway" \
  "Deploy all configured MCP servers to a running gateway instance." \
  "./scripts/mcp-gateway-deploy.sh --config my-gateway-config.json --gateway-url http://gateway.example.com:8080"

# Example 10: Health Monitoring
show_example \
  "Monitor Server Health" \
  "Run health checks on all deployed MCP servers and view status dashboard." \
  "./scripts/mcp-gateway-health.sh"

# Example 11: Kubernetes Deployment
show_example \
  "Deploy to Kubernetes" \
  "Deploy all MCP servers to a Kubernetes cluster using the provided manifests." \
  "./scripts/quick-start.sh kubernetes"

# Example 12: Testing
show_example \
  "Run Integration Tests" \
  "Test that all Docker images and scripts are working correctly." \
  "./scripts/test-servers.sh all"

# Example 13: Scaling with Docker Compose
show_example \
  "Scale Services" \
  "Scale a specific service to multiple instances for load distribution." \
  "docker-compose up -d --scale mcp-memory=3"

# Example 14: View Logs
show_example \
  "View Server Logs" \
  "View real-time logs from all services or specific ones." \
  "docker-compose logs -f mcp-memory
# Or for all services:
docker-compose logs -f"

# Example 15: Stop and Clean Up
show_example \
  "Stop and Clean Up" \
  "Stop all services and remove containers and networks." \
  "docker-compose down
# Or with volumes:
docker-compose down -v"

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Examples Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "For more information, see:"
echo "  - DOCKER_DEPLOYMENT.md - Comprehensive deployment guide"
echo "  - docker-compose.yml - Service configuration"
echo "  - k8s/ - Kubernetes manifests"
echo "  - scripts/ - All helper scripts"
echo ""
echo "Quick reference:"
echo "  Start:    ./scripts/quick-start.sh"
echo "  Health:   ./scripts/mcp-gateway-health.sh"
echo "  Test:     ./scripts/test-servers.sh"
echo "  Stop:     docker-compose down"
echo ""
