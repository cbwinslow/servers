# MCP Servers - Scripts Directory

This directory contains all helper scripts for building, deploying, and managing MCP servers.

## 📋 Script Overview

### Docker Build & Push

- **`docker-build-all.sh`** - Build all MCP server Docker images
  ```bash
  ./docker-build-all.sh [--push] [--registry REGISTRY] [--platform PLATFORMS]
  ```

- **`docker-push-ghcr.sh`** - Push images to GitHub Container Registry
  ```bash
  export GITHUB_USERNAME=your-username
  export GITHUB_TOKEN=your-token
  ./docker-push-ghcr.sh [SERVER_NAME]
  ```

- **`docker-push-dockerhub.sh`** - Push images to Docker Hub
  ```bash
  export DOCKERHUB_USERNAME=your-username
  export DOCKERHUB_TOKEN=your-token
  ./docker-push-dockerhub.sh [SERVER_NAME]
  ```

### MCP Gateway

- **`mcp-gateway-config.sh`** - Generate MCP gateway configuration
  ```bash
  ./mcp-gateway-config.sh [--output FILE] [--host HOST] [--port PORT]
  ```

- **`mcp-gateway-deploy.sh`** - Deploy servers to MCP gateway
  ```bash
  ./mcp-gateway-deploy.sh [--config FILE] [--gateway-url URL]
  ```

- **`mcp-gateway-health.sh`** - Monitor server health
  ```bash
  ./mcp-gateway-health.sh [--gateway-url URL]
  ```

### Deployment & Testing

- **`quick-start.sh`** - One-command deployment
  ```bash
  ./quick-start.sh [MODE]
  # Modes: docker-compose, kubernetes, build
  ```

- **`test-servers.sh`** - Integration testing
  ```bash
  ./test-servers.sh [MODE]
  # Modes: docker, containers, all
  ```

- **`examples.sh`** - Interactive usage examples
  ```bash
  ./examples.sh
  ```

## 🚀 Common Workflows

### Deploy Everything

```bash
./quick-start.sh
```

### Build and Push to GHCR

```bash
export GITHUB_USERNAME=your-username
export GITHUB_TOKEN=your-token
./docker-build-all.sh --push --registry ghcr.io/$GITHUB_USERNAME
```

### Configure and Deploy to Gateway

```bash
./mcp-gateway-config.sh --output config.json
./mcp-gateway-deploy.sh --config config.json
./mcp-gateway-health.sh
```

### Monitor Running Servers

```bash
# One-time check
./mcp-gateway-health.sh

# Continuous monitoring
watch -n 5 ./mcp-gateway-health.sh
```

## 🔧 Script Features

All scripts include:
- ✅ Colored output for readability
- ✅ Error handling
- ✅ Help text and documentation
- ✅ Exit codes for automation
- ✅ Configurable parameters

## 📚 Documentation

For detailed information, see:
- [DOCKER_DEPLOYMENT.md](../DOCKER_DEPLOYMENT.md) - Comprehensive deployment guide
- [DOCKER_SUMMARY.md](../DOCKER_SUMMARY.md) - Architecture and overview
- [README.md](../README.md) - Main repository README

## 🤝 Contributing

When adding new scripts:
1. Follow existing naming conventions
2. Add help text and documentation
3. Include error handling
4. Make scripts executable (`chmod +x`)
5. Update this README
6. Add tests in `test-servers.sh`

## 📝 License

MIT License - Same as main repository
