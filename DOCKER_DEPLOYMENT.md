# MCP Servers - Docker & Production Deployment Guide

This guide covers deploying MCP (Model Context Protocol) servers using Docker containers, either to Docker Hub, GitHub Container Registry (GHCR), or through an MCP gateway.

## Table of Contents

- [Quick Start](#quick-start)
- [Building Docker Images](#building-docker-images)
- [Pushing to Container Registries](#pushing-to-container-registries)
- [Docker Compose Deployment](#docker-compose-deployment)
- [Kubernetes Deployment](#kubernetes-deployment)
- [MCP Gateway Integration](#mcp-gateway-integration)
- [Production Considerations](#production-considerations)
- [Troubleshooting](#troubleshooting)

## Quick Start

Deploy all MCP servers with Docker Compose in one command:

```bash
./scripts/quick-start.sh
```

This will:
1. Check prerequisites (Docker, Docker Compose)
2. Pull pre-built images from GHCR
3. Start all MCP servers
4. Run health checks

## Building Docker Images

### Build All Servers

Build all MCP servers as multi-architecture Docker images:

```bash
./scripts/docker-build-all.sh
```

Options:
- `--push` - Push images to registry after building
- `--registry REGISTRY` - Specify container registry (default: `ghcr.io/cbwinslow`)
- `--platform PLATFORMS` - Target platforms (default: `linux/amd64,linux/arm64`)

### Build Individual Server

To build a specific server:

```bash
cd src/[server-name]
docker build -t my-registry/mcp-server-[server-name]:latest -f Dockerfile ../..
```

## Pushing to Container Registries

### GitHub Container Registry (GHCR)

1. Create a GitHub Personal Access Token with `write:packages` permission
2. Set environment variables:

```bash
export GITHUB_USERNAME=your-username
export GITHUB_TOKEN=your-token
```

3. Build and push:

```bash
./scripts/docker-build-all.sh --push --registry ghcr.io/$GITHUB_USERNAME
```

Or push existing images:

```bash
./scripts/docker-push-ghcr.sh
```

### Docker Hub

1. Set environment variables:

```bash
export DOCKERHUB_USERNAME=your-username
export DOCKERHUB_TOKEN=your-token
```

2. Build and push:

```bash
./scripts/docker-build-all.sh --push --registry docker.io/$DOCKERHUB_USERNAME
```

Or push existing images:

```bash
./scripts/docker-push-dockerhub.sh
```

## Docker Compose Deployment

### Starting Services

```bash
# Start all services in background
docker-compose up -d

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f mcp-memory
```

### Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Service Configuration

Edit `docker-compose.yml` to customize:
- Port mappings
- Volume mounts
- Environment variables
- Resource limits

Example customization:

```yaml
services:
  mcp-filesystem:
    volumes:
      - /path/to/your/data:/data:ro
      - /path/to/your/projects:/projects:ro
```

## Kubernetes Deployment

### Prerequisites

- kubectl configured with access to your cluster
- Container images pushed to accessible registry

### Deploy to Kubernetes

```bash
# Using quick start script
./scripts/quick-start.sh kubernetes

# Or manually
kubectl apply -f k8s/
```

### Verify Deployment

```bash
# Check pods
kubectl get pods -n mcp-servers

# Check services
kubectl get services -n mcp-servers

# View logs
kubectl logs -f -n mcp-servers deployment/mcp-memory
```

### Customize Kubernetes Deployment

Edit files in `k8s/` directory:
- `00-namespace.yaml` - Namespace configuration
- `10-deployments.yaml` - Deployment and service definitions

Adjust:
- Resource requests/limits
- Number of replicas
- Persistent volume sizes
- Service types (ClusterIP, NodePort, LoadBalancer)

## MCP Gateway Integration

MCP Gateway allows you to route requests to multiple MCP servers through a single endpoint.

### Generate Gateway Configuration

```bash
./scripts/mcp-gateway-config.sh --output mcp-gateway-config.json
```

This creates a configuration file with:
- Server definitions
- Routing strategies
- Health check settings
- Security policies

### Deploy to Gateway

```bash
./scripts/mcp-gateway-deploy.sh \
  --config mcp-gateway-config.json \
  --gateway-url http://your-gateway:8080
```

### Monitor Gateway Health

```bash
# One-time check
./scripts/mcp-gateway-health.sh

# Continuous monitoring
watch -n 5 ./scripts/mcp-gateway-health.sh
```

## Production Considerations

### Security

1. **Authentication**: Enable authentication in gateway configuration
2. **Network Isolation**: Use private networks/VPCs
3. **Secrets Management**: Use environment variables or secrets managers
4. **TLS/SSL**: Enable HTTPS for all external endpoints

### Scaling

1. **Horizontal Scaling**: Increase replicas in Kubernetes or docker-compose
2. **Load Balancing**: Use gateway routing strategies
3. **Resource Limits**: Set appropriate CPU and memory limits

### Monitoring

1. **Health Checks**: Use provided health check scripts
2. **Logging**: Configure centralized logging (ELK, Splunk, etc.)
3. **Metrics**: Export metrics to Prometheus/Grafana
4. **Alerts**: Set up alerts for service failures

### Persistence

For servers with state (e.g., mcp-memory):
- Use named volumes in Docker Compose
- Use PersistentVolumeClaims in Kubernetes
- Regular backups of data volumes

### Resource Requirements

Minimum recommended resources per server:

| Server | CPU | Memory | Storage |
|--------|-----|--------|---------|
| everything | 100m | 128Mi | - |
| fetch | 100m | 128Mi | - |
| filesystem | 100m | 128Mi | (mounted) |
| git | 100m | 256Mi | (mounted) |
| memory | 100m | 256Mi | 10Gi |
| sequentialthinking | 100m | 128Mi | - |
| time | 100m | 128Mi | - |

Scale up based on load.

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs mcp-[server-name]

# Or with docker-compose
docker-compose logs mcp-[server-name]
```

### Network Issues

```bash
# Check network
docker network inspect mcp-network

# Verify container connectivity
docker exec mcp-memory ping mcp-everything
```

### Volume/Permission Issues

```bash
# Check volume
docker volume inspect mcp-memory-data

# Check mounted directory permissions
ls -la /path/to/mounted/directory
```

### Building Issues

```bash
# Clean build cache
docker builder prune

# Build with no cache
docker build --no-cache ...
```

### Gateway Connection Issues

1. Verify gateway is running and accessible
2. Check gateway logs for errors
3. Verify network connectivity between services
4. Check firewall rules

### Health Check Failures

```bash
# Manual health check
./scripts/mcp-gateway-health.sh

# Check individual container
docker exec mcp-[server-name] [health-check-command]
```

## Available MCP Servers

- **everything** - Reference/test server with comprehensive features
- **fetch** - Web content fetching and conversion
- **filesystem** - Secure file operations with access controls
- **git** - Git repository operations
- **memory** - Knowledge graph-based persistent memory
- **sequentialthinking** - Dynamic problem-solving
- **time** - Time and timezone conversion

## Support

For issues or questions:
- Check existing [GitHub Issues](https://github.com/cbwinslow/servers/issues)
- Review [MCP Documentation](https://modelcontextprotocol.io)
- Consult server-specific README files in `src/[server-name]/`

## License

MIT License - See LICENSE file for details
