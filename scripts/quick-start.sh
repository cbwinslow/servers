#!/bin/bash
# Quick start script for deploying MCP servers in production
# Usage: ./quick-start.sh [--mode MODE]

set -e

# Default values
MODE="${1:-docker-compose}"

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      MCP Servers - Production Quick Start               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Function to check prerequisites
check_prerequisites() {
  echo -e "${YELLOW}Checking prerequisites...${NC}"
  
  # Check Docker
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
  fi
  echo -e "${GREEN}✓ Docker is installed${NC}"
  
  # Check Docker Compose (if needed)
  if [ "$MODE" = "docker-compose" ]; then
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
      echo -e "${RED}✗ Docker Compose is not installed${NC}"
      echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
      exit 1
    fi
    echo -e "${GREEN}✓ Docker Compose is installed${NC}"
  fi
  
  # Check kubectl (if needed)
  if [ "$MODE" = "kubernetes" ]; then
    if ! command -v kubectl &> /dev/null; then
      echo -e "${RED}✗ kubectl is not installed${NC}"
      echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
      exit 1
    fi
    echo -e "${GREEN}✓ kubectl is installed${NC}"
  fi
  
  echo ""
}

# Function to deploy with Docker Compose
deploy_docker_compose() {
  echo -e "${YELLOW}Deploying with Docker Compose...${NC}"
  echo ""
  
  cd "$ROOT_DIR"
  
  # Pull images
  echo "Pulling images..."
  docker-compose pull
  
  # Start services
  echo "Starting services..."
  docker-compose up -d
  
  echo ""
  echo -e "${GREEN}✓ Services started!${NC}"
  echo ""
  echo "View logs: docker-compose logs -f"
  echo "Stop services: docker-compose down"
  echo ""
}

# Function to deploy with Kubernetes
deploy_kubernetes() {
  echo -e "${YELLOW}Deploying with Kubernetes...${NC}"
  echo ""
  
  cd "$ROOT_DIR"
  
  # Apply manifests
  if [ -d "k8s" ]; then
    kubectl apply -f k8s/
    
    echo ""
    echo -e "${GREEN}✓ Kubernetes resources created!${NC}"
    echo ""
    echo "View pods: kubectl get pods -n mcp-servers"
    echo "View services: kubectl get services -n mcp-servers"
    echo "View logs: kubectl logs -f -n mcp-servers <pod-name>"
  else
    echo -e "${RED}✗ Kubernetes manifests not found in k8s/ directory${NC}"
    exit 1
  fi
}

# Function to build images locally
build_local() {
  echo -e "${YELLOW}Building images locally...${NC}"
  echo ""
  
  "$SCRIPT_DIR/docker-build-all.sh"
  
  echo ""
  echo -e "${GREEN}✓ Images built!${NC}"
}

# Main execution
echo "Deployment mode: $MODE"
echo ""

case $MODE in
  docker-compose)
    check_prerequisites
    deploy_docker_compose
    ;;
  kubernetes|k8s)
    check_prerequisites
    deploy_kubernetes
    ;;
  build)
    check_prerequisites
    build_local
    ;;
  *)
    echo -e "${RED}Unknown mode: $MODE${NC}"
    echo ""
    echo "Usage: $0 [MODE]"
    echo ""
    echo "Modes:"
    echo "  docker-compose - Deploy using Docker Compose (default)"
    echo "  kubernetes     - Deploy to Kubernetes cluster"
    echo "  build          - Build images locally"
    exit 1
    ;;
esac

# Post-deployment checks
echo -e "${YELLOW}Running post-deployment checks...${NC}"
sleep 5

if [ "$MODE" = "docker-compose" ]; then
  "$SCRIPT_DIR/mcp-gateway-health.sh" || true
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Deployment Complete!                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "1. Check server health: ./scripts/mcp-gateway-health.sh"
echo "2. Generate gateway config: ./scripts/mcp-gateway-config.sh"
echo "3. View logs to verify everything is working"
echo ""
