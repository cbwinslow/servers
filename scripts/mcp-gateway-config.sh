#!/bin/bash
# Generate MCP Gateway configuration for all servers
# Usage: ./mcp-gateway-config.sh [--output FILE]

set -e

# Default values
OUTPUT_FILE="mcp-gateway-config.json"
GATEWAY_HOST="${GATEWAY_HOST:-localhost}"
GATEWAY_PORT="${GATEWAY_PORT:-8080}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --output|-o)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --host)
      GATEWAY_HOST="$2"
      shift 2
      ;;
    --port)
      GATEWAY_PORT="$2"
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
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Generating MCP Gateway Configuration${NC}"
echo "Output file: $OUTPUT_FILE"
echo ""

# Generate configuration
cat > "$OUTPUT_FILE" << 'EOF'
{
  "gateway": {
    "name": "MCP Server Gateway",
    "version": "1.0.0",
    "host": "GATEWAY_HOST",
    "port": GATEWAY_PORT
  },
  "servers": {
    "everything": {
      "name": "Everything Server",
      "description": "Reference/test server with prompts, resources, and tools",
      "transport": "stdio",
      "command": "docker",
      "args": ["run", "-i", "--rm", "ghcr.io/cbwinslow/mcp-server-everything:latest"],
      "enabled": true,
      "tags": ["reference", "test", "comprehensive"]
    },
    "fetch": {
      "name": "Fetch Server",
      "description": "Web content fetching and conversion for efficient LLM usage",
      "transport": "stdio",
      "command": "docker",
      "args": ["run", "-i", "--rm", "ghcr.io/cbwinslow/mcp-server-fetch:latest"],
      "enabled": true,
      "tags": ["web", "fetch", "content"]
    },
    "filesystem": {
      "name": "Filesystem Server",
      "description": "Secure file operations with configurable access controls",
      "transport": "stdio",
      "command": "docker",
      "args": ["run", "-i", "--rm", "-v", "${PWD}/data:/data:ro", "ghcr.io/cbwinslow/mcp-server-filesystem:latest", "/data"],
      "enabled": true,
      "tags": ["filesystem", "files", "storage"]
    },
    "git": {
      "name": "Git Server",
      "description": "Tools to read, search, and manipulate Git repositories",
      "transport": "stdio",
      "command": "docker",
      "args": ["run", "-i", "--rm", "-v", "${PWD}/repos:/repos:ro", "ghcr.io/cbwinslow/mcp-server-git:latest", "--repository", "/repos"],
      "enabled": true,
      "tags": ["git", "vcs", "repositories"]
    },
    "memory": {
      "name": "Memory Server",
      "description": "Knowledge graph-based persistent memory system",
      "transport": "stdio",
      "command": "docker",
      "args": ["run", "-i", "--rm", "-v", "mcp-memory-data:/data", "ghcr.io/cbwinslow/mcp-server-memory:latest"],
      "enabled": true,
      "tags": ["memory", "knowledge-graph", "persistence"]
    },
    "sequentialthinking": {
      "name": "Sequential Thinking Server",
      "description": "Dynamic and reflective problem-solving through thought sequences",
      "transport": "stdio",
      "command": "docker",
      "args": ["run", "-i", "--rm", "ghcr.io/cbwinslow/mcp-server-sequentialthinking:latest"],
      "enabled": true,
      "tags": ["thinking", "reasoning", "problem-solving"]
    },
    "time": {
      "name": "Time Server",
      "description": "Time and timezone conversion capabilities",
      "transport": "stdio",
      "command": "docker",
      "args": ["run", "-i", "--rm", "ghcr.io/cbwinslow/mcp-server-time:latest"],
      "enabled": true,
      "tags": ["time", "timezone", "conversion"]
    }
  },
  "routing": {
    "strategy": "round-robin",
    "healthCheck": {
      "enabled": true,
      "interval": 30,
      "timeout": 10,
      "retries": 3
    }
  },
  "security": {
    "authentication": {
      "enabled": false,
      "type": "bearer"
    },
    "rateLimit": {
      "enabled": true,
      "requests": 100,
      "window": 60
    }
  },
  "logging": {
    "level": "info",
    "format": "json",
    "output": "stdout"
  }
}
EOF

# Replace placeholders
sed -i "s/GATEWAY_HOST/$GATEWAY_HOST/g" "$OUTPUT_FILE"
sed -i "s/GATEWAY_PORT/$GATEWAY_PORT/g" "$OUTPUT_FILE"

echo -e "${GREEN}✓ Configuration generated successfully!${NC}"
echo ""
echo -e "${YELLOW}Configuration file: $OUTPUT_FILE${NC}"
echo -e "${YELLOW}Gateway endpoint: http://$GATEWAY_HOST:$GATEWAY_PORT${NC}"
echo ""
echo "You can customize this configuration to match your MCP gateway implementation."
