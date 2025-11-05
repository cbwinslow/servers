# 🐳 Docker Deployment Quick Reference

This repository includes comprehensive Docker deployment support for all MCP servers!

## Quick Start (One Command)

Deploy all MCP servers instantly:

```bash
./scripts/quick-start.sh
```

## What's Included

### 📦 Pre-built Docker Images

All MCP servers are available as multi-architecture Docker images:

```bash
# Pull from GitHub Container Registry
docker pull ghcr.io/cbwinslow/mcp-server-memory:latest

# Or from Docker Hub
docker pull cbwinslow/mcp-server-memory:latest
```

### 🚀 Deployment Options

1. **Docker Compose** - For single-host deployments
2. **Kubernetes** - For production clusters
3. **MCP Gateway** - For unified routing

### 📜 Available Scripts

| Script | Purpose |
|--------|---------|
| `docker-build-all.sh` | Build all MCP server images |
| `docker-push-ghcr.sh` | Push to GitHub Container Registry |
| `docker-push-dockerhub.sh` | Push to Docker Hub |
| `mcp-gateway-config.sh` | Generate gateway configuration |
| `mcp-gateway-deploy.sh` | Deploy to MCP gateway |
| `mcp-gateway-health.sh` | Monitor server health |
| `quick-start.sh` | One-command deployment |

## Usage Examples

### Using Docker Compose

```bash
# Start all servers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop servers
docker-compose down
```

### Using Docker Directly

```bash
# Run individual server
docker run -it --rm ghcr.io/cbwinslow/mcp-server-fetch:latest

# With volume mount
docker run -it --rm \
  -v $(pwd)/data:/data:ro \
  ghcr.io/cbwinslow/mcp-server-filesystem:latest /data
```

### Building Custom Images

```bash
# Build all servers
./scripts/docker-build-all.sh

# Build with custom registry
./scripts/docker-build-all.sh --registry my-registry.com/my-org

# Build and push
./scripts/docker-build-all.sh --push --registry ghcr.io/my-username
```

### MCP Gateway Integration

```bash
# Generate gateway config
./scripts/mcp-gateway-config.sh

# Deploy to gateway
./scripts/mcp-gateway-deploy.sh --gateway-url http://my-gateway:8080

# Monitor health
./scripts/mcp-gateway-health.sh
```

## 📚 Full Documentation

See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for:
- Detailed deployment instructions
- Production best practices
- Kubernetes manifests
- Troubleshooting guide
- Security considerations

## Available Servers

All 7 MCP reference servers are containerized:

- **everything** - Reference/test server
- **fetch** - Web content fetching
- **filesystem** - Secure file operations
- **git** - Git repository tools
- **memory** - Knowledge graph memory
- **sequentialthinking** - Problem-solving
- **time** - Time/timezone conversion

## Environment Configuration

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
# Edit .env with your settings
```

## CI/CD Integration

Automated builds are configured via GitHub Actions:
- Builds on every push to main
- Multi-architecture support (amd64, arm64)
- Automatic pushes to GHCR and Docker Hub

---

For the original MCP documentation, see below ⬇️

---
