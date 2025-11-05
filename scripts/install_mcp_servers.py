#!/usr/bin/env python3
"""
Script to install MCP servers into VSCode, Windsurf, Cursor, and Claude Desktop
with Bitwarden integration for API key management
"""

import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional, List


class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color


class Logger:
    """Simple logger for colored output"""
    
    @staticmethod
    def info(message: str):
        print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")
    
    @staticmethod
    def success(message: str):
        print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")
    
    @staticmethod
    def warning(message: str):
        print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")
    
    @staticmethod
    def error(message: str):
        print(f"{Colors.RED}[ERROR]{Colors.NC} {message}", file=sys.stderr)


class MCPInstaller:
    """Main installer class for MCP servers"""
    
    # MCP server configurations
    TYPESCRIPT_SERVERS = {
        "memory": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-memory"]
        },
        "filesystem": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-filesystem"]
        },
        "everything": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-everything"]
        },
        "sequentialthinking": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-sequentialthinking"]
        }
    }
    
    PYTHON_SERVERS = {
        "git": {
            "command": "uvx",
            "args": ["mcp-server-git"]
        },
        "fetch": {
            "command": "uvx",
            "args": ["mcp-server-fetch"]
        },
        "time": {
            "command": "uvx",
            "args": ["mcp-server-time"]
        }
    }
    
    def __init__(self):
        self.os_type = self._detect_os()
        self.bitwarden_available = False
        self._check_bitwarden()
    
    @staticmethod
    def _detect_os() -> str:
        """Detect the operating system"""
        system = platform.system()
        if system == "Darwin":
            return "macos"
        elif system == "Linux":
            return "linux"
        elif system == "Windows":
            return "windows"
        else:
            return "unknown"
    
    @staticmethod
    def _command_exists(command: str) -> bool:
        """Check if a command exists in PATH"""
        return shutil.which(command) is not None
    
    def _check_bitwarden(self):
        """Check if Bitwarden CLI is available and unlocked"""
        if not self._command_exists("bw"):
            Logger.warning("Bitwarden CLI (bw) not found. API keys will need to be configured manually.")
            return
        
        try:
            result = subprocess.run(
                ["bw", "status"],
                capture_output=True,
                text=True,
                check=False
            )
            status_data = json.loads(result.stdout)
            if status_data.get("status") == "unlocked":
                self.bitwarden_available = True
                Logger.success("Bitwarden CLI is available and unlocked")
            else:
                Logger.warning("Bitwarden vault is locked. Please unlock it with: bw unlock")
        except (subprocess.SubprocessError, json.JSONDecodeError, KeyError):
            Logger.warning("Could not determine Bitwarden status")
    
    def get_api_key_from_bitwarden(self, key_name: str) -> Optional[str]:
        """Retrieve API key from Bitwarden"""
        if not self.bitwarden_available:
            return None
        
        try:
            # Search for the item
            result = subprocess.run(
                ["bw", "list", "items", "--search", key_name],
                capture_output=True,
                text=True,
                check=True
            )
            items = json.loads(result.stdout)
            
            if not items:
                Logger.warning(f"API key '{key_name}' not found in Bitwarden")
                return None
            
            item_id = items[0].get("id")
            if not item_id:
                return None
            
            # Get the password
            result = subprocess.run(
                ["bw", "get", "password", item_id],
                capture_output=True,
                text=True,
                check=True
            )
            
            api_key = result.stdout.strip()
            if api_key:
                Logger.success(f"Retrieved '{key_name}' from Bitwarden")
                return api_key
            
        except (subprocess.SubprocessError, json.JSONDecodeError, KeyError, IndexError):
            Logger.warning(f"Could not retrieve API key for '{key_name}'")
        
        return None
    
    def get_config_dir(self, ide: str) -> Optional[Path]:
        """Get configuration directory for an IDE based on OS"""
        home = Path.home()
        
        config_paths = {
            "macos": {
                "vscode": home / "Library/Application Support/Code/User",
                "cursor": home / "Library/Application Support/Cursor/User",
                "windsurf": home / "Library/Application Support/Windsurf/User",
                "claude": home / "Library/Application Support/Claude",
            },
            "linux": {
                "vscode": home / ".config/Code/User",
                "cursor": home / ".config/Cursor/User",
                "windsurf": home / ".config/Windsurf/User",
                "claude": home / ".config/Claude",
            },
            "windows": {
                "vscode": Path(os.getenv("APPDATA", "")) / "Code/User",
                "cursor": Path(os.getenv("APPDATA", "")) / "Cursor/User",
                "windsurf": Path(os.getenv("APPDATA", "")) / "Windsurf/User",
                "claude": Path(os.getenv("APPDATA", "")) / "Claude",
            }
        }
        
        return config_paths.get(self.os_type, {}).get(ide)
    
    def check_prerequisites(self) -> bool:
        """Check if required tools are installed"""
        Logger.info("Checking prerequisites...")
        
        missing_deps = []
        
        if not self._command_exists("npx"):
            missing_deps.append("npx (Node.js)")
        
        if not self._command_exists("uvx") and not self._command_exists("uv"):
            missing_deps.append("uv/uvx (Python package manager)")
        
        if missing_deps:
            Logger.error(f"Missing required dependencies: {', '.join(missing_deps)}")
            Logger.info("Please install missing dependencies:")
            Logger.info("  - npx: Install Node.js from https://nodejs.org/")
            Logger.info("  - uv: Install with: curl -LsSf https://astral.sh/uv/install.sh | sh")
            return False
        
        Logger.success("All prerequisites are installed")
        return True
    
    def backup_file(self, file_path: Path) -> Path:
        """Create a backup of a file"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = file_path.with_suffix(f".backup.{timestamp}{file_path.suffix}")
        shutil.copy2(file_path, backup_path)
        Logger.info(f"Backed up existing file to {backup_path.name}")
        return backup_path
    
    def configure_vscode_like(self, ide: str, workspace_folder: Optional[str] = None):
        """Configure VSCode-like editors (VSCode, Cursor, Windsurf)"""
        Logger.info(f"Configuring {ide}...")
        
        config_dir = self.get_config_dir(ide)
        if not config_dir:
            Logger.error(f"Could not determine config directory for {ide}")
            return
        
        settings_file = config_dir / "settings.json"
        
        # Create directory if it doesn't exist
        if not config_dir.exists():
            Logger.warning(f"{ide} config directory not found. Creating: {config_dir}")
            config_dir.mkdir(parents=True, exist_ok=True)
        
        # Load or create settings
        settings = {}
        if settings_file.exists():
            try:
                with open(settings_file, 'r') as f:
                    settings = json.load(f)
                self.backup_file(settings_file)
            except json.JSONDecodeError:
                Logger.warning("Existing settings.json is invalid, creating new one")
                settings = {}
        else:
            Logger.info("Created new settings.json")
        
        # Build MCP servers configuration
        mcp_servers = {}
        
        # Add TypeScript servers
        for name, config in self.TYPESCRIPT_SERVERS.items():
            server_config = config.copy()
            # Add workspace folder for filesystem server
            if name == "filesystem" and workspace_folder:
                server_config["args"] = server_config["args"] + [workspace_folder]
            elif name == "filesystem":
                server_config["args"] = server_config["args"] + ["${workspaceFolder}"]
            mcp_servers[name] = server_config
        
        # Add Python servers
        for name, config in self.PYTHON_SERVERS.items():
            server_config = config.copy()
            # Add repository argument for git server
            if name == "git" and workspace_folder:
                server_config["args"] = server_config["args"] + ["--repository", workspace_folder]
            elif name == "git":
                server_config["args"] = server_config["args"] + ["--repository", "${workspaceFolder}"]
            mcp_servers[name] = server_config
        
        # Update settings
        settings["mcpServers"] = mcp_servers
        
        # Write settings
        with open(settings_file, 'w') as f:
            json.dump(settings, f, indent=2)
        
        Logger.success(f"Configured {ide} with MCP servers")
    
    def configure_claude(self, default_path: Optional[str] = None):
        """Configure Claude Desktop"""
        Logger.info("Configuring Claude Desktop...")
        
        config_dir = self.get_config_dir("claude")
        if not config_dir:
            Logger.error("Could not determine config directory for Claude Desktop")
            return
        
        config_file = config_dir / "claude_desktop_config.json"
        
        # Create directory if it doesn't exist
        if not config_dir.exists():
            Logger.warning(f"Claude config directory not found. Creating: {config_dir}")
            config_dir.mkdir(parents=True, exist_ok=True)
        
        # Load or create config
        config = {"mcpServers": {}}
        if config_file.exists():
            try:
                with open(config_file, 'r') as f:
                    config = json.load(f)
                self.backup_file(config_file)
            except json.JSONDecodeError:
                Logger.warning("Existing config is invalid, creating new one")
                config = {"mcpServers": {}}
        else:
            Logger.info("Created new claude_desktop_config.json")
        
        # Build MCP servers configuration
        mcp_servers = {}
        
        # Add TypeScript servers
        for name, server_config in self.TYPESCRIPT_SERVERS.items():
            config_copy = server_config.copy()
            # Add default path for filesystem server
            if name == "filesystem":
                path = default_path or str(Path.home() / "Documents")
                config_copy["args"] = config_copy["args"] + [path]
            mcp_servers[name] = config_copy
        
        # Add Python servers
        for name, server_config in self.PYTHON_SERVERS.items():
            config_copy = server_config.copy()
            # Add repository argument for git server if default_path is provided
            if name == "git" and default_path:
                config_copy["args"] = config_copy["args"] + ["--repository", default_path]
            mcp_servers[name] = config_copy
        
        # Try to add GitHub server with token from Bitwarden
        github_token = self.get_api_key_from_bitwarden("GITHUB_PERSONAL_ACCESS_TOKEN")
        if github_token:
            mcp_servers["github"] = {
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-github"],
                "env": {
                    "GITHUB_PERSONAL_ACCESS_TOKEN": github_token
                }
            }
        else:
            Logger.warning("GitHub token not found. GitHub MCP server will need manual configuration.")
        
        # Update config
        config["mcpServers"] = mcp_servers
        
        # Write config
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        
        Logger.success("Configured Claude Desktop with MCP servers")
    
    def install(self, ides: List[str], workspace_folder: Optional[str] = None):
        """Main installation method"""
        Logger.info("MCP Server Installation Script")
        Logger.info("===============================")
        print()
        
        # Check prerequisites
        if not self.check_prerequisites():
            sys.exit(1)
        print()
        
        # Configure each selected IDE
        for ide in ides:
            if ide in ["vscode", "cursor", "windsurf"]:
                self.configure_vscode_like(ide, workspace_folder)
            elif ide == "claude":
                self.configure_claude(workspace_folder)
            print()
        
        Logger.success("Installation complete!")
        print()
        Logger.info("Next steps:")
        Logger.info("1. Restart your IDE(s) for changes to take effect")
        Logger.info("2. Review the generated configuration files")
        Logger.info("3. Add any required API keys if not using Bitwarden")
        Logger.info("4. Test MCP servers by asking your AI assistant to use them")


def main():
    parser = argparse.ArgumentParser(
        description="Install and configure MCP servers for various IDEs",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --vscode                    Configure only VSCode
  %(prog)s --cursor --windsurf         Configure Cursor and Windsurf
  %(prog)s --all                       Configure all supported IDEs
  %(prog)s --all --workspace ~/projects  Configure with specific workspace

Prerequisites:
  - Node.js (for npx)
  - uv/uvx (for Python servers)
  - Bitwarden CLI (optional, for API key management)

API Key Management:
  This script can retrieve API keys from Bitwarden if:
  1. Bitwarden CLI (bw) is installed
  2. You are logged in and vault is unlocked
  3. API keys are stored with recognizable names (e.g., "GITHUB_PERSONAL_ACCESS_TOKEN")

  To unlock your Bitwarden vault:
    bw login
    bw unlock
    export BW_SESSION="<session_key>"
        """
    )
    
    parser.add_argument("--vscode", action="store_true", help="Configure VSCode")
    parser.add_argument("--cursor", action="store_true", help="Configure Cursor")
    parser.add_argument("--windsurf", action="store_true", help="Configure Windsurf")
    parser.add_argument("--claude", action="store_true", help="Configure Claude Desktop")
    parser.add_argument("--all", action="store_true", help="Configure all supported IDEs")
    parser.add_argument("--workspace", type=str, help="Default workspace folder path")
    
    args = parser.parse_args()
    
    # Determine which IDEs to configure
    ides = []
    if args.all:
        ides = ["vscode", "cursor", "windsurf", "claude"]
    else:
        if args.vscode:
            ides.append("vscode")
        if args.cursor:
            ides.append("cursor")
        if args.windsurf:
            ides.append("windsurf")
        if args.claude:
            ides.append("claude")
    
    if not ides:
        parser.print_help()
        sys.exit(0)
    
    # Create installer and run
    installer = MCPInstaller()
    installer.install(ides, args.workspace)


if __name__ == "__main__":
    main()
