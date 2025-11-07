#!/bin/bash
# Script to install MCP servers into VSCode, Windsurf, and Cursor
# with Bitwarden integration for API key management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos";;
        Linux*)     echo "linux";;
        MINGW*|MSYS*|CYGWIN*)  echo "windows";;
        *)          echo "unknown";;
    esac
}

# Function to get config directory based on OS and IDE
get_config_dir() {
    local ide=$1
    local os=$(detect_os)
    
    case "$os" in
        macos)
            case "$ide" in
                vscode)     echo "$HOME/Library/Application Support/Code/User";;
                cursor)     echo "$HOME/Library/Application Support/Cursor/User";;
                windsurf)   echo "$HOME/Library/Application Support/Windsurf/User";;
                claude)     echo "$HOME/Library/Application Support/Claude";;
            esac
            ;;
        linux)
            case "$ide" in
                vscode)     echo "$HOME/.config/Code/User";;
                cursor)     echo "$HOME/.config/Cursor/User";;
                windsurf)   echo "$HOME/.config/Windsurf/User";;
                claude)     echo "$HOME/.config/Claude";;
            esac
            ;;
        windows)
            case "$ide" in
                vscode)     echo "$APPDATA/Code/User";;
                cursor)     echo "$APPDATA/Cursor/User";;
                windsurf)   echo "$APPDATA/Windsurf/User";;
                claude)     echo "$APPDATA/Claude";;
            esac
            ;;
    esac
}

# Function to check if Bitwarden CLI is installed and logged in
check_bitwarden() {
    if ! command_exists bw; then
        print_warning "Bitwarden CLI (bw) not found. API keys will need to be configured manually."
        return 1
    fi
    
    # Check if logged in
    if ! bw status | grep -q '"status":"unlocked"'; then
        print_warning "Bitwarden vault is locked. Please unlock it with: bw unlock"
        return 1
    fi
    
    return 0
}

# Function to get API key from Bitwarden
get_api_key_from_bitwarden() {
    local key_name=$1
    
    if ! check_bitwarden; then
        return 1
    fi
    
    # Validate key_name to prevent command injection
    # Only allow alphanumeric, underscore, and hyphen
    if ! [[ "$key_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_warning "Invalid key name '$key_name': only alphanumeric, underscore, and hyphen allowed"
        return 1
    fi
    
    # Try to find the item in Bitwarden using validated input
    local item_id=$(bw list items --search "$key_name" 2>/dev/null | jq -r '.[0].id // empty')
    
    if [ -z "$item_id" ]; then
        print_warning "API key '$key_name' not found in Bitwarden"
        return 1
    fi
    
    # Get the password/API key
    local api_key=$(bw get password "$item_id" 2>/dev/null)
    
    if [ -z "$api_key" ]; then
        print_warning "Could not retrieve API key for '$key_name'"
        return 1
    fi
    
    echo "$api_key"
    return 0
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check for Node.js/npm (for npx)
    if ! command_exists npx; then
        missing_deps+=("npx (Node.js)")
    fi
    
    # Check for Python/uv (for uvx)
    if ! command_exists uvx && ! command_exists uv; then
        missing_deps+=("uv/uvx (Python package manager)")
    fi
    
    # Check for jq (for JSON manipulation)
    if ! command_exists jq; then
        missing_deps+=("jq (JSON processor)")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install missing dependencies before running this script."
        print_info "  - npx: Install Node.js from https://nodejs.org/"
        print_info "  - uv: Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
        print_info "  - jq: Install with your package manager (brew install jq, apt install jq, etc.)"
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Function to create or update settings.json for VSCode-like editors
configure_vscode_like() {
    local ide=$1
    local config_dir=$(get_config_dir "$ide")
    local settings_file="$config_dir/settings.json"
    
    print_info "Configuring $ide..."
    
    # Create directory if it doesn't exist
    if [ ! -d "$config_dir" ]; then
        print_warning "$ide config directory not found. Creating: $config_dir"
        mkdir -p "$config_dir"
    fi
    
    # Create settings.json if it doesn't exist
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
        print_info "Created new settings.json"
    fi
    
    # Backup existing settings
    cp "$settings_file" "$settings_file.backup.$(date +%Y%m%d_%H%M%S)"
    print_info "Backed up existing settings"
    
    # Create MCP servers configuration
    local mcp_config=$(cat <<'MCPCONFIG'
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
    },
    "fetch": {
      "command": "uvx",
      "args": ["mcp-server-fetch"]
    },
    "everything": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-everything"]
    },
    "sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequentialthinking"]
    },
    "time": {
      "command": "uvx",
      "args": ["mcp-server-time"]
    }
  }
}
MCPCONFIG
)
    
    # Merge MCP configuration into existing settings
    if ! jq -s '.[0] * .[1]' "$settings_file" <(echo "$mcp_config") > "$settings_file.tmp"; then
        print_error "Failed to merge MCP configuration"
        rm -f "$settings_file.tmp"
        return 1
    fi
    mv "$settings_file.tmp" "$settings_file"
    
    print_success "Configured $ide with MCP servers"
}

# Function to configure Claude Desktop
configure_claude() {
    local config_dir=$(get_config_dir "claude")
    local config_file="$config_dir/claude_desktop_config.json"
    
    print_info "Configuring Claude Desktop..."
    
    # Create directory if it doesn't exist
    if [ ! -d "$config_dir" ]; then
        print_warning "Claude config directory not found. Creating: $config_dir"
        mkdir -p "$config_dir"
    fi
    
    # Create config file if it doesn't exist
    if [ ! -f "$config_file" ]; then
        echo '{"mcpServers":{}}' > "$config_file"
        print_info "Created new claude_desktop_config.json"
    fi
    
    # Backup existing config
    cp "$config_file" "$config_file.backup.$(date +%Y%m%d_%H%M%S)"
    print_info "Backed up existing config"
    
    # Try to get GitHub token from Bitwarden
    local github_token=""
    if github_token=$(get_api_key_from_bitwarden "GITHUB_PERSONAL_ACCESS_TOKEN"); then
        print_success "Retrieved GitHub token from Bitwarden"
    else
        print_warning "GitHub token not found in Bitwarden. GitHub MCP server will need manual configuration."
        github_token="<YOUR_TOKEN>"
    fi
    
    # Create MCP servers configuration with environment variables
    local mcp_servers=$(cat <<MCPSERVERS
{
  "memory": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"]
  },
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME/Documents"]
  },
  "git": {
    "command": "uvx",
    "args": ["mcp-server-git"]
  },
  "fetch": {
    "command": "uvx",
    "args": ["mcp-server-fetch"]
  },
  "everything": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-everything"]
  },
  "sequentialthinking": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequentialthinking"]
  },
  "time": {
    "command": "uvx",
    "args": ["mcp-server-time"]
  }
}
MCPSERVERS
)
    
    # Add GitHub server if token is available (using jq --arg for safe string interpolation)
    if [ "$github_token" != "<YOUR_TOKEN>" ]; then
        mcp_servers=$(echo "$mcp_servers" | jq --arg token "$github_token" '. + {"github": {"command": "npx", "args": ["-y", "@modelcontextprotocol/server-github"], "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": $token}}}')
    fi
    
    # Update config file with error handling
    if ! jq --argjson servers "$mcp_servers" '.mcpServers = $servers' "$config_file" > "$config_file.tmp"; then
        print_error "Failed to update configuration"
        rm -f "$config_file.tmp"
        return 1
    fi
    mv "$config_file.tmp" "$config_file"
    
    print_success "Configured Claude Desktop with MCP servers"
}

# Function to display usage
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Install and configure MCP servers for various IDEs

OPTIONS:
    --vscode        Configure VSCode
    --cursor        Configure Cursor
    --windsurf      Configure Windsurf
    --claude        Configure Claude Desktop
    --all           Configure all supported IDEs
    --help          Display this help message

EXAMPLES:
    $0 --vscode             # Configure only VSCode
    $0 --cursor --windsurf  # Configure Cursor and Windsurf
    $0 --all                # Configure all supported IDEs

PREREQUISITES:
    - Node.js (for npx)
    - uv/uvx (for Python servers)
    - jq (for JSON processing)
    - Bitwarden CLI (optional, for API key management)

API KEY MANAGEMENT:
    This script can retrieve API keys from Bitwarden if:
    1. Bitwarden CLI (bw) is installed
    2. You are logged in and vault is unlocked
    3. API keys are stored with recognizable names (e.g., "GITHUB_PERSONAL_ACCESS_TOKEN")

    To unlock your Bitwarden vault:
        bw login
        bw unlock
        export BW_SESSION="<session_key>"

EOF
}

# Main script
main() {
    local configure_vscode=false
    local configure_cursor=false
    local configure_windsurf=false
    local configure_claude=false
    
    # Parse command line arguments
    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --vscode)
                configure_vscode=true
                ;;
            --cursor)
                configure_cursor=true
                ;;
            --windsurf)
                configure_windsurf=true
                ;;
            --claude)
                configure_claude=true
                ;;
            --all)
                configure_vscode=true
                configure_cursor=true
                configure_windsurf=true
                configure_claude=true
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
    
    print_info "MCP Server Installation Script"
    print_info "==============================="
    echo
    
    # Check prerequisites
    check_prerequisites
    echo
    
    # Check Bitwarden status
    if check_bitwarden; then
        print_success "Bitwarden CLI is available and unlocked"
    else
        print_warning "Bitwarden integration disabled. API keys will need manual configuration."
    fi
    echo
    
    # Configure selected IDEs
    if [ "$configure_vscode" = true ]; then
        configure_vscode_like "vscode"
        echo
    fi
    
    if [ "$configure_cursor" = true ]; then
        configure_vscode_like "cursor"
        echo
    fi
    
    if [ "$configure_windsurf" = true ]; then
        configure_vscode_like "windsurf"
        echo
    fi
    
    if [ "$configure_claude" = true ]; then
        configure_claude
        echo
    fi
    
    print_success "Installation complete!"
    echo
    print_info "Next steps:"
    print_info "1. Restart your IDE(s) for changes to take effect"
    print_info "2. Review the generated configuration files"
    print_info "3. Add any required API keys if not using Bitwarden"
    print_info "4. Test MCP servers by asking your AI assistant to use them"
}

# Run main function
main "$@"
