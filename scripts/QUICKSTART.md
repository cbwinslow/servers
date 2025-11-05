# Quick Start Guide: Installing MCP Servers

This guide will help you quickly install MCP servers into your preferred IDE.

## Prerequisites (5 minutes)

1. **Install Node.js** (for TypeScript MCP servers)
   ```bash
   # Check if already installed
   npx --version
   
   # If not installed, download from https://nodejs.org/
   ```

2. **Install uv** (for Python MCP servers)
   ```bash
   # Install uv
   curl -LsSf https://astral.sh/uv/install.sh | sh
   
   # Verify installation
   uvx --version
   ```

3. **Optional: Install Bitwarden CLI** (for API key management)
   ```bash
   # macOS
   brew install bitwarden-cli
   
   # npm (cross-platform)
   npm install -g @bitwarden/cli
   
   # Then unlock your vault
   bw login
   bw unlock
   export BW_SESSION="<your-session-key>"
   ```

## Installation (1 minute)

### Option 1: Install for All IDEs (Recommended)

```bash
# Clone or navigate to the repository
cd /path/to/servers

# Run the installation script
./scripts/install_mcp_servers.py --all
```

### Option 2: Install for Specific IDEs

```bash
# VSCode only
./scripts/install_mcp_servers.py --vscode

# Cursor and Windsurf
./scripts/install_mcp_servers.py --cursor --windsurf

# Claude Desktop
./scripts/install_mcp_servers.py --claude
```

### Using Bash Script (Alternative)

If you prefer bash:

```bash
./scripts/install_mcp_servers.sh --all
```

## What Gets Installed

The script installs these MCP servers:

| Server | Description | Command |
|--------|-------------|---------|
| **memory** | Knowledge graph memory system | `npx` |
| **filesystem** | Secure file operations | `npx` |
| **git** | Git repository tools | `uvx` |
| **fetch** | Web content fetching | `uvx` |
| **everything** | Test/reference server | `npx` |
| **sequentialthinking** | Problem-solving tools | `npx` |
| **time** | Time/timezone tools | `uvx` |

## Verify Installation

1. **Restart your IDE** - This is important!

2. **Check the configuration file** was created:
   - **VSCode/Cursor/Windsurf**: `settings.json` in your IDE's User directory
   - **Claude Desktop**: `claude_desktop_config.json` in Claude's config directory

3. **Test an MCP tool**:
   - Open your AI assistant (Claude, Copilot, etc.)
   - Try: "What files are in this directory?" (tests filesystem)
   - Try: "What's the git status?" (tests git)
   - Try: "Remember that I prefer Python" (tests memory)

## Troubleshooting

### Script Can't Find Prerequisites

```bash
# Install Node.js from https://nodejs.org/
# Then install uv:
curl -LsSf https://astral.sh/uv/install.sh | sh

# Restart your terminal
source ~/.bashrc  # or ~/.zshrc
```

### IDE Config Directory Not Found

1. Launch your IDE at least once
2. The config directory should be created automatically
3. Run the script again

### MCP Servers Not Working

Test manually:
```bash
# Test TypeScript server
npx -y @modelcontextprotocol/server-memory

# Test Python server
uvx mcp-server-git

# If these work, the issue is with your IDE configuration
```

## Next Steps

1. **Explore the servers**: Try different MCP commands in your AI assistant
2. **Add API keys**: For servers that need them (GitHub, etc.)
3. **Customize**: Edit the config files to adjust server settings
4. **Add more servers**: Check the main README for community servers

## Common Use Cases

### Development Workflow
```
- "Show me the git status" (git)
- "Create a new file called README.md" (filesystem)
- "Commit these changes with message 'Initial commit'" (git)
```

### Research and Learning
```
- "Fetch the content from https://example.com" (fetch)
- "Remember that I'm learning React" (memory)
- "What time is it in Tokyo?" (time)
```

### File Management
```
- "List all Python files in this directory" (filesystem)
- "Read the contents of package.json" (filesystem)
- "Search for files containing 'TODO'" (filesystem)
```

## Getting Help

- **Documentation**: [scripts/README.md](README.md)
- **Examples**: [scripts/EXAMPLES.md](EXAMPLES.md)
- **MCP Protocol**: https://modelcontextprotocol.io
- **Issues**: https://github.com/modelcontextprotocol/servers/issues

## Manual Installation (Alternative)

If you prefer manual configuration, see the [full documentation](README.md#manual-configuration).

---

**Time to completion**: ~6 minutes (including prerequisites)

**Supported platforms**: macOS, Linux, Windows

**Supported IDEs**: VSCode, Cursor, Windsurf, Claude Desktop
