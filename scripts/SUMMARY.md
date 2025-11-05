# MCP Server Installation Scripts - Summary

## Overview

This directory contains automated installation scripts for Model Context Protocol (MCP) servers, designed to work with VSCode, Cursor, Windsurf, and Claude Desktop.

## What's Included

### Installation Scripts

1. **install_mcp_servers.py** (Recommended)
   - Cross-platform Python script
   - No external dependencies except Python 3
   - More robust error handling
   - ~450 lines of well-documented code

2. **install_mcp_servers.sh**
   - Bash script for Unix-like systems
   - Requires `jq` for JSON processing
   - Alternative to Python script
   - ~350 lines of bash code

### Documentation

1. **README.md** - Complete documentation with all features and options
2. **QUICKSTART.md** - Get started in 5 minutes
3. **EXAMPLES.md** - Configuration examples and customization
4. **TROUBLESHOOTING.md** - Solutions to common issues

## Key Features

✅ **Multi-IDE Support**
- VSCode
- Cursor
- Windsurf  
- Claude Desktop

✅ **Bitwarden Integration**
- Automatic API key retrieval
- Secure credential management
- Optional - manual configuration still supported

✅ **Safety Features**
- Automatic backups of existing configs
- Non-destructive - only modifies MCP sections
- Validates JSON before writing

✅ **Cross-Platform**
- macOS
- Linux
- Windows

## Quick Usage

```bash
# Install for all IDEs
./scripts/install_mcp_servers.py --all

# Install for specific IDEs
./scripts/install_mcp_servers.py --vscode --cursor

# Show help
./scripts/install_mcp_servers.py --help
```

## MCP Servers Installed

The scripts install these reference MCP servers:

| Server | Type | Description |
|--------|------|-------------|
| memory | TypeScript | Knowledge graph memory |
| filesystem | TypeScript | File operations |
| everything | TypeScript | Test/reference server |
| sequentialthinking | TypeScript | Problem-solving |
| git | Python | Git repository tools |
| fetch | Python | Web content fetching |
| time | Python | Time/timezone tools |

## Prerequisites

**Required:**
- Node.js (for TypeScript servers via npx)
- uv (for Python servers via uvx)

**Optional:**
- Bitwarden CLI (for API key management)
- jq (only for bash script)

## Documentation Structure

```
scripts/
├── install_mcp_servers.py     # Python installation script
├── install_mcp_servers.sh     # Bash installation script
├── README.md                  # Complete documentation
├── QUICKSTART.md             # 5-minute setup guide
├── EXAMPLES.md               # Configuration examples
├── TROUBLESHOOTING.md        # Common issues & solutions
└── SUMMARY.md                # This file
```

## Typical Workflow

1. **Install Prerequisites** (one-time)
   ```bash
   # Install Node.js from https://nodejs.org/
   # Install uv
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Optional: Setup Bitwarden** (one-time)
   ```bash
   bw login
   bw unlock
   export BW_SESSION="<session-key>"
   ```

3. **Run Installation Script**
   ```bash
   ./scripts/install_mcp_servers.py --all
   ```

4. **Restart IDE(s)**
   - Important: Fully restart, not just reload

5. **Test MCP Servers**
   - Ask AI: "What files are in this directory?"
   - Ask AI: "Remember that I prefer Python"
   - Ask AI: "What's the git status?"

## Configuration Files

The scripts modify these files:

**VSCode/Cursor/Windsurf:**
- File: `settings.json`
- Location: IDE's User directory
- Section: `mcpServers`

**Claude Desktop:**
- File: `claude_desktop_config.json`
- Location: Claude's config directory
- Section: `mcpServers`

## Bitwarden Integration

If Bitwarden CLI is installed and unlocked:

1. Script searches for API keys by name
2. Automatically populates configuration
3. Supported key names:
   - `GITHUB_PERSONAL_ACCESS_TOKEN`
   - Others as documented in individual servers

If not using Bitwarden:
- Script warns but continues
- API keys must be added manually
- See EXAMPLES.md for manual configuration

## Safety & Backups

Every time you run the script:

1. **Backup created** with timestamp
   - Format: `settings.json.backup.YYYYMMDD_HHMMSS`
   - Stored in same directory as original

2. **Non-destructive updates**
   - Only `mcpServers` section is modified
   - Other settings preserved

3. **Validation**
   - JSON syntax validated before writing
   - Errors reported clearly

## Customization

After installation, you can:

1. **Add more servers** - Edit config file manually
2. **Modify arguments** - Adjust server parameters
3. **Add environment variables** - Include API keys
4. **Remove servers** - Delete unwanted entries

See EXAMPLES.md for customization patterns.

## Support & Help

| Need | Resource |
|------|----------|
| Quick setup | [QUICKSTART.md](QUICKSTART.md) |
| Full docs | [README.md](README.md) |
| Examples | [EXAMPLES.md](EXAMPLES.md) |
| Issues | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| MCP docs | https://modelcontextprotocol.io |
| Bug reports | GitHub Issues |

## Development

Scripts are designed to be:
- **Idempotent** - Safe to run multiple times
- **Modular** - Easy to extend for new servers
- **Well-documented** - Clear code comments
- **Testable** - Can run in dry-run mode

## Testing

```bash
# Test Python script
python3 scripts/install_mcp_servers.py --help

# Test bash script  
bash scripts/install_mcp_servers.sh --help

# Dry run (doesn't modify files)
# Not yet implemented - scripts always create backups
```

## License

These scripts are part of the Model Context Protocol servers repository and are licensed under the MIT License. See the main repository LICENSE file.

## Contributing

Improvements welcome:
- Additional IDE support
- More robust error handling
- Additional API key sources (1Password, etc.)
- Automated testing
- GUI wrapper

## Version History

- **v1.0** (2025-01) - Initial release
  - Python and Bash scripts
  - Multi-IDE support
  - Bitwarden integration
  - Comprehensive documentation

## Credits

Created for the Model Context Protocol project by the community.

---

**Quick Start**: [QUICKSTART.md](QUICKSTART.md)  
**Full Documentation**: [README.md](README.md)  
**Need Help?**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
