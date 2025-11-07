# Makefile for MCP Servers - Docker Deployment

.PHONY: help build push deploy clean test health

# Default target
help:
	@echo "MCP Servers - Docker Deployment Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build          - Build all Docker images locally"
	@echo "  build-push     - Build and push images to registries"
	@echo "  deploy         - Deploy using Docker Compose"
	@echo "  deploy-k8s     - Deploy to Kubernetes"
	@echo "  test           - Run integration tests"
	@echo "  health         - Check server health"
	@echo "  gateway-config - Generate MCP gateway configuration"
	@echo "  gateway-deploy - Deploy to MCP gateway"
	@echo "  logs           - View Docker Compose logs"
	@echo "  clean          - Stop and remove all containers"
	@echo "  clean-all      - Clean everything including volumes"
	@echo "  examples       - Show usage examples"
	@echo ""

# Build all Docker images
build:
	@echo "Building all MCP server images..."
	./scripts/docker-build-all.sh

# Build and push to registries
build-push:
	@echo "Building and pushing all MCP server images..."
	./scripts/docker-build-all.sh --push

# Deploy with Docker Compose
deploy:
	@echo "Deploying MCP servers with Docker Compose..."
	./scripts/quick-start.sh docker-compose

# Deploy to Kubernetes
deploy-k8s:
	@echo "Deploying MCP servers to Kubernetes..."
	./scripts/quick-start.sh kubernetes

# Run tests
test:
	@echo "Running integration tests..."
	./scripts/test-servers.sh all

# Check health
health:
	@echo "Checking server health..."
	./scripts/mcp-gateway-health.sh

# Generate gateway config
gateway-config:
	@echo "Generating MCP gateway configuration..."
	./scripts/mcp-gateway-config.sh

# Deploy to gateway
gateway-deploy:
	@echo "Deploying to MCP gateway..."
	./scripts/mcp-gateway-deploy.sh

# View logs
logs:
	@echo "Viewing Docker Compose logs..."
	docker-compose logs -f

# Stop and remove containers
clean:
	@echo "Stopping and removing containers..."
	docker-compose down

# Clean everything including volumes
clean-all:
	@echo "Cleaning everything..."
	docker-compose down -v
	docker system prune -f

# Show examples
examples:
	@./scripts/examples.sh

# Development helpers
dev-build:
	@echo "Building for development..."
	./scripts/docker-build-all.sh --platform linux/amd64

dev-test:
	@echo "Running quick tests..."
	./scripts/test-servers.sh docker

# Push to specific registries
push-ghcr:
	@echo "Pushing to GitHub Container Registry..."
	./scripts/docker-push-ghcr.sh

push-dockerhub:
	@echo "Pushing to Docker Hub..."
	./scripts/docker-push-dockerhub.sh

# Quick start shortcuts
start: deploy
stop: clean
restart: clean deploy

# Status check
status:
	@echo "=== Docker Containers ==="
	@docker ps --filter "name=mcp-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "No containers running"
	@echo ""
	@echo "=== Docker Images ==="
	@docker images | grep mcp-server || echo "No MCP images found"
	@echo ""
	@echo "=== Docker Volumes ==="
	@docker volume ls | grep mcp || echo "No MCP volumes found"
