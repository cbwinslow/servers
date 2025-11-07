# Troubleshooting Guide

Common issues and solutions when using the MCP server installation scripts.

## Prerequisites Issues

### "npx: command not found"

**Problem**: Node.js is not installed or not in PATH

**Solution**:
```bash
# Download and install Node.js from https://nodejs.org/

# Verify installation
node --version
npx --version

# If installed but not found, add to PATH:
export PATH="$PATH:/usr/local/bin"  # Linux/macOS
```

### "uvx: command not found"

**Problem**: uv is not installed or not in PATH

**Solution**:
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Restart terminal or source your profile
source ~/.bashrc  # or ~/.zshrc on macOS

# Verify installation
uvx --version
uv --version
```

### "jq: command not found" (Bash script only)

**Problem**: jq JSON processor not installed

**Solution**:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq

# Windows (using Chocolatey)
choco install jq
```

## Bitwarden Issues

### "Bitwarden vault is locked"

**Problem**: Bitwarden CLI vault is locked

**Solution**:
```bash
# Unlock vault
bw unlock

# Export session key (copy from unlock output)
export BW_SESSION="your-session-key-here"

# Verify status
bw status
```

### "API key not found in Bitwarden"

**Problem**: Script can't find API keys in Bitwarden

**Solution**:

1. Check item name in Bitwarden matches exactly:
   - `GITHUB_PERSONAL_ACCESS_TOKEN`
   - Other standard key names

2. Verify the API key is in the password field:
   ```bash
   bw list items --search "GITHUB_PERSONAL_ACCESS_TOKEN"
   ```

3. Manual retrieval test:
   ```bash
   bw get password <item-id>
   ```

### "Could not retrieve API key"

**Problem**: Bitwarden CLI returns empty or error

**Solution**:
```bash
# Ensure vault is synced
bw sync

# Check if you can list items
bw list items

# Verify session is active
bw status | jq '.status'  # Should be "unlocked"
```

## Configuration Issues

### "IDE config directory not found"

**Problem**: Script reports IDE directory doesn't exist

**Solution**:

1. Launch the IDE at least once to create config directory
2. Check if IDE is installed in standard location
3. Manually create directory:
   ```bash
   # macOS VSCode
   mkdir -p "$HOME/Library/Application Support/Code/User"
   
   # Linux VSCode
   mkdir -p "$HOME/.config/Code/User"
   
   # Windows VSCode (PowerShell)
   New-Item -Path "$env:APPDATA\Code\User" -ItemType Directory -Force
   ```

### "Existing settings.json is invalid"

**Problem**: Current settings.json has syntax errors

**Solution**:

1. Script will create backup automatically
2. Fix JSON syntax errors in original file:
   ```bash
   # Validate JSON
   cat settings.json | jq .
   ```

3. Or let script create new settings.json:
   ```bash
   mv settings.json settings.json.old
   # Run script again
   ```

### "Permission denied"

**Problem**: Can't write to configuration files

**Solution**:
```bash
# Check file permissions
ls -l "path/to/settings.json"

# Fix permissions
chmod 644 "path/to/settings.json"

# If directory permissions
chmod 755 "path/to/User"
```

## Runtime Issues

### MCP Servers Not Showing in IDE

**Problem**: Configured servers don't appear in IDE

**Solution**:

1. **Restart IDE completely** (not just reload window)
2. Check configuration file syntax:
   ```bash
   # Validate JSON
   cat settings.json | jq .
   ```
3. Look for IDE-specific MCP extension/plugin
4. Check IDE console for errors

### Server Fails to Start

**Problem**: MCP server starts but immediately crashes

**Solution**:

1. Test server manually:
   ```bash
   # TypeScript server
   npx -y @modelcontextprotocol/server-memory
   
   # Python server
   uvx mcp-server-git
   ```

2. Check server logs (location varies by IDE)

3. Verify required dependencies:
   ```bash
   # For git server
   git --version
   
   # For filesystem server - no additional deps
   ```

### "Module not found" Error

**Problem**: Server can't find required modules

**Solution**:

1. Clear npm cache:
   ```bash
   npm cache clean --force
   ```

2. Clear uv cache:
   ```bash
   uv cache clean
   ```

3. Reinstall server:
   ```bash
   # TypeScript
   npm install -g @modelcontextprotocol/server-memory
   
   # Python
   pip install mcp-server-git
   ```

## Platform-Specific Issues

### macOS: "Developer Cannot Be Verified"

**Problem**: macOS security blocks execution

**Solution**:
```bash
# Allow script execution
chmod +x scripts/install_mcp_servers.sh
chmod +x scripts/install_mcp_servers.py

# If blocked by Gatekeeper
xattr -d com.apple.quarantine scripts/install_mcp_servers.sh
xattr -d com.apple.quarantine scripts/install_mcp_servers.py
```

### Windows: "Execution Policy" Error

**Problem**: PowerShell blocks script execution

**Solution**:
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Or use Python script directly
python scripts\install_mcp_servers.py --all
```

### Linux: "Bad Interpreter" Error

**Problem**: Script can't find bash/python

**Solution**:
```bash
# Use explicit interpreter
bash scripts/install_mcp_servers.sh --all
python3 scripts/install_mcp_servers.py --all

# Or fix shebang
which bash  # Copy path
# Edit script's first line to match
```

## IDE-Specific Issues

### VSCode

**Problem**: Settings not taking effect

**Solution**:
1. Check User vs Workspace settings
2. Use Command Palette: "Preferences: Open Settings (JSON)"
3. Verify `mcpServers` is in correct scope

### Cursor

**Problem**: Cursor doesn't recognize MCP servers

**Solution**:
1. Ensure Cursor is up to date
2. Check for Cursor-specific MCP extension
3. Configuration file: `~/Library/Application Support/Cursor/User/settings.json`

### Windsurf

**Problem**: Configuration doesn't load

**Solution**:
1. Verify Windsurf version supports MCP
2. Check Windsurf documentation for MCP setup
3. May require specific MCP extension

### Claude Desktop

**Problem**: Servers not appearing in Claude

**Solution**:
1. **Fully quit Claude** (not just close window)
2. Verify config file location:
   - macOS: `~/Library/Application Support/Claude/`
   - Windows: `%APPDATA%\Claude\`
3. Check file name is exactly: `claude_desktop_config.json`
4. Restart Claude Desktop

## Testing and Verification

### Test Individual Server

```bash
# Test memory server
npx -y @modelcontextprotocol/server-memory

# Should start without errors
# Press Ctrl+C to stop

# Test git server
uvx mcp-server-git --repository .

# Should start without errors
```

### Verify Configuration Syntax

```bash
# Check JSON syntax
python3 -c "import json; json.load(open('settings.json'))"

# Or use jq
cat settings.json | jq .

# Should not show any errors
```

### Check Server Connectivity

In your AI assistant:
1. List available tools/commands
2. Try a simple command: "What time is it?" (tests time server)
3. Check IDE/app logs for MCP activity

## Getting More Help

### Enable Debug Logging

Most IDEs support verbose logging:

**VSCode**:
```json
{
  "mcp.logging": "verbose"
}
```

**Claude Desktop**:
Check logs at:
- macOS: `~/Library/Logs/Claude/`
- Windows: `%APPDATA%\Claude\logs\`

### Collect Diagnostic Info

Before reporting issues:

```bash
# System info
uname -a
python3 --version
node --version
npx --version
uvx --version

# Test servers manually
npx -y @modelcontextprotocol/server-memory &
uvx mcp-server-git &

# Check if processes start
ps aux | grep mcp

# Kill test processes
pkill -f mcp
```

### Report Issues

When reporting issues, include:

1. Operating system and version
2. IDE and version
3. Node.js version (`node --version`)
4. Python/uv version (`python3 --version`, `uv --version`)
5. Full error message
6. Configuration file (redact sensitive data)
7. Steps to reproduce

## Recovery

### Reset to Default

If everything breaks:

```bash
# 1. Restore from backup
cp settings.json.backup.20250105_143022 settings.json

# 2. Or start fresh
rm settings.json
# Run script again

# 3. Manual configuration
# See EXAMPLES.md for manual setup
```

### Uninstall MCP Servers

Remove from configuration:

```bash
# Edit settings.json
# Remove "mcpServers" section
# Or remove individual servers
```

Clean up globally installed packages:

```bash
# List npm global packages
npm list -g --depth=0

# Remove specific package
npm uninstall -g @modelcontextprotocol/server-memory

# For uv, packages are not global
# They're cached per-invocation
```

## Still Having Issues?

1. Check [README.md](README.md) for detailed documentation
2. Review [EXAMPLES.md](EXAMPLES.md) for configuration samples
3. Visit https://modelcontextprotocol.io for MCP protocol documentation
4. Open an issue: https://github.com/modelcontextprotocol/servers/issues
