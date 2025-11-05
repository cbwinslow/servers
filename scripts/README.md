# MCP Server Installation Scripts

These scripts automate the installation and configuration of Model Context Protocol (MCP) servers for various IDEs including VSCode, Cursor, Windsurf, and Claude Desktop. They also support Bitwarden CLI integration for secure API key management.

## Features

- ✅ **Multi-IDE Support**: Configure VSCode, Cursor, Windsurf, and Claude Desktop
- 🔒 **Bitwarden Integration**: Automatically populate API keys from Bitwarden vault
- 🔄 **Automatic Backup**: Creates backups of existing configuration files
- 🌍 **Cross-Platform**: Works on macOS, Linux, and Windows
- 📦 **All MCP Servers**: Installs all reference MCP servers from this repository
  - TypeScript servers: memory, filesystem, everything, sequentialthinking
  - Python servers: git, fetch, time

## Prerequisites

### Required

1. **Node.js** (for npx to run TypeScript MCP servers)
   - Install from: https://nodejs.org/
   - Verify: `npx --version`

2. **uv/uvx** (for Python MCP servers)
   - Install: `curl -LsSf https://astral.sh/uv/install.sh | sh`
   - Verify: `uvx --version`

### Optional (for Bash script)

3. **jq** (JSON processor - only needed for bash script)
   - macOS: `brew install jq`
   - Ubuntu/Debian: `apt install jq`
   - Windows: Download from https://stedolan.github.io/jq/

### Optional (for API key management)

4. **Bitwarden CLI** (for automatic API key population)
   - Install: https://bitwarden.com/help/cli/
   - Verify: `bw --version`

## Quick Start

### Using Python Script (Recommended)

```bash
# Configure all IDEs
./scripts/install_mcp_servers.py --all

# Configure specific IDEs
./scripts/install_mcp_servers.py --vscode --cursor

# Configure with a specific workspace folder
./scripts/install_mcp_servers.py --all --workspace ~/projects
```

### Using Bash Script

```bash
# Configure all IDEs
./scripts/install_mcp_servers.sh --all

# Configure specific IDEs
./scripts/install_mcp_servers.sh --vscode --cursor

# Show help
./scripts/install_mcp_servers.sh --help
```

## Usage

### Command Line Options

Both scripts support the same command-line options:

```
--vscode        Configure VSCode
--cursor        Configure Cursor
--windsurf      Configure Windsurf
--claude        Configure Claude Desktop
--all           Configure all supported IDEs
--workspace     Specify default workspace folder (Python script only)
--help          Display help message
```

### Examples

1. **Configure only VSCode**:
   ```bash
   ./scripts/install_mcp_servers.py --vscode
   ```

2. **Configure Cursor and Windsurf**:
   ```bash
   ./scripts/install_mcp_servers.py --cursor --windsurf
   ```

3. **Configure all IDEs with a workspace**:
   ```bash
   ./scripts/install_mcp_servers.py --all --workspace ~/my-projects
   ```

4. **Configure Claude Desktop only**:
   ```bash
   ./scripts/install_mcp_servers.py --claude
   ```

## Bitwarden Integration

The scripts can automatically retrieve API keys from your Bitwarden vault if you have the Bitwarden CLI installed and your vault unlocked.

### Setup Bitwarden

1. **Install Bitwarden CLI**:
   ```bash
   # macOS
   brew install bitwarden-cli
   
   # npm
   npm install -g @bitwarden/cli
   ```

2. **Login and unlock your vault**:
   ```bash
   bw login
   bw unlock
   ```

3. **Export the session key** (from the unlock command output):
   ```bash
   export BW_SESSION="your-session-key"
   ```

### Storing API Keys in Bitwarden

Store your API keys in Bitwarden with recognizable names:

- `GITHUB_PERSONAL_ACCESS_TOKEN` - GitHub API token
- `ANTHROPIC_API_KEY` - Anthropic API key (if needed)
- Other service API keys as needed

The scripts will automatically search for these entries and populate the configuration files.

## Configuration Files

The scripts modify the following configuration files:

### VSCode, Cursor, Windsurf

- **macOS**: `~/Library/Application Support/{IDE}/User/settings.json`
- **Linux**: `~/.config/{IDE}/User/settings.json`
- **Windows**: `%APPDATA%\{IDE}\User\settings.json`

Example configuration added:
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${workspaceFolder}"]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "${workspaceFolder}"]
    }
  }
}
```

### Claude Desktop

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

Example configuration:
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<automatically-populated-from-bitwarden>"
      }
    }
  }
}
```

## MCP Servers Installed

The scripts install the following MCP servers:

### TypeScript Servers (via npx)

1. **memory** - Knowledge graph-based persistent memory system
2. **filesystem** - Secure file operations with configurable access controls
3. **everything** - Reference/test server with prompts, resources, and tools
4. **sequentialthinking** - Dynamic and reflective problem-solving through thought sequences

### Python Servers (via uvx)

1. **git** - Tools to read, search, and manipulate Git repositories
2. **fetch** - Web content fetching and conversion for efficient LLM usage
3. **time** - Time and timezone conversion capabilities

## Backup and Safety

The scripts automatically:

- Create timestamped backups of existing configuration files
- Only modify the `mcpServers` section of configuration files
- Preserve all other settings in your configuration files

Backup files are named with the pattern:
```
settings.json.backup.20250105_143022
claude_desktop_config.json.backup.20250105_143022
```

## Troubleshooting

### Prerequisites Not Found

If you see errors about missing prerequisites:

```bash
# Install Node.js
# Download from https://nodejs.org/

# Install uv/uvx
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install jq (bash script only)
brew install jq  # macOS
apt install jq   # Linux
```

### Bitwarden Issues

If Bitwarden integration isn't working:

```bash
# Check if Bitwarden CLI is installed
bw --version

# Check vault status
bw status

# Unlock vault if locked
bw unlock

# Export session key (from unlock output)
export BW_SESSION="your-session-key"
```

### Configuration Not Taking Effect

1. Restart your IDE completely
2. Check the configuration file was created correctly
3. Verify the MCP servers can be run manually:
   ```bash
   npx -y @modelcontextprotocol/server-memory
   uvx mcp-server-git
   ```

### IDE Not Found

If the script reports an IDE directory not found:

1. Ensure the IDE is installed
2. Launch the IDE at least once to create config directories
3. Manually create the config directory if needed

## Manual Configuration

If you prefer to configure manually or need to add API keys:

1. Open the configuration file for your IDE
2. Edit the `mcpServers` section
3. Add or modify server configurations
4. Add environment variables with API keys:
   ```json
   {
     "command": "npx",
     "args": ["-y", "@modelcontextprotocol/server-github"],
     "env": {
       "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token-here"
       }
   }
   ```

## Next Steps

After running the installation script:

1. **Restart your IDE(s)** - Configuration changes require a restart
2. **Test the servers** - Ask your AI assistant to use the MCP servers
3. **Review configuration** - Check the generated config files
4. **Add API keys** - If not using Bitwarden, manually add required API keys
5. **Customize** - Modify server arguments or add new servers as needed

## Examples of MCP Server Usage

Once installed, you can ask your AI assistant things like:

- "Create a new file called test.txt with some content" (filesystem)
- "What files are in this directory?" (filesystem)
- "Commit these changes with message 'Update README'" (git)
- "Remember that I prefer using TypeScript for new projects" (memory)
- "What time is it in Tokyo?" (time)
- "Fetch the content from https://example.com" (fetch)

## Support

For issues or questions:

- Check the main repository README: [README.md](../README.md)
- Review MCP documentation: https://modelcontextprotocol.io
- Open an issue on GitHub

## License

These scripts are part of the Model Context Protocol servers repository and are licensed under the MIT License.
