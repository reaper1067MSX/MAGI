#!/bin/bash
# =============================================================================
# Ralph for Linux - Installation Script
# =============================================================================
#
# Supports: Ubuntu, Debian, Raspberry Pi OS, and other Linux distributions
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash
#
# Or:
#   ./install.sh [options]
#
# Options:
#   --agent <name>    Install specific agent (gemini, ollama, claude)
#   --all             Install all available agents
#   --deps-only       Only install dependencies
#   --help            Show help
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}$1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
        OS_NAME=$PRETTY_NAME
    elif [[ -f /etc/debian_version ]]; then
        OS="debian"
        OS_VERSION=$(cat /etc/debian_version)
        OS_NAME="Debian $OS_VERSION"
    else
        OS="unknown"
        OS_NAME="Unknown Linux"
    fi

    # Detect Raspberry Pi
    if [[ -f /proc/device-tree/model ]]; then
        if grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
            IS_RPI="true"
            RPI_MODEL=$(cat /proc/device-tree/model | tr -d '\0')
        fi
    fi

    # Detect architecture
    ARCH=$(uname -m)
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root. Consider running as regular user with sudo."
    fi
}

# Install system dependencies
install_dependencies() {
    log_info "Installing system dependencies..."

    case $OS in
        ubuntu|debian|raspbian)
            sudo apt-get update -qq
            sudo apt-get install -y -qq curl jq git
            ;;
        fedora)
            sudo dnf install -y curl jq git
            ;;
        centos|rhel)
            sudo yum install -y curl jq git
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm curl jq git
            ;;
        *)
            log_warning "Unknown OS. Please install manually: curl, jq, git"
            ;;
    esac

    log_success "System dependencies installed"
}

# Install Node.js (for Gemini CLI)
install_nodejs() {
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        log_success "Node.js already installed: $node_version"
        return 0
    fi

    log_info "Installing Node.js..."

    case $OS in
        ubuntu|debian|raspbian)
            # Use NodeSource for latest LTS
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        fedora)
            sudo dnf install -y nodejs npm
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm nodejs npm
            ;;
        *)
            log_warning "Please install Node.js manually from https://nodejs.org"
            return 1
            ;;
    esac

    log_success "Node.js installed: $(node --version)"
}

# Install Gemini CLI
install_gemini() {
    log_info "Installing Gemini CLI..."

    if ! command -v npm &> /dev/null; then
        install_nodejs
    fi

    sudo npm install -g @google/gemini-cli

    if command -v gemini &> /dev/null; then
        log_success "Gemini CLI installed"
        log_info "Run 'gemini auth login' to authenticate"
    else
        log_error "Gemini CLI installation failed"
        return 1
    fi
}

# Install Ollama
install_ollama() {
    log_info "Installing Ollama..."

    if command -v ollama &> /dev/null; then
        log_success "Ollama already installed"
        return 0
    fi

    # Ollama install script
    curl -fsSL https://ollama.com/install.sh | sh

    if command -v ollama &> /dev/null; then
        log_success "Ollama installed"

        # Suggest models
        echo ""
        log_info "Recommended models for coding:"
        echo "  ollama pull codellama:13b      # Good balance"
        echo "  ollama pull deepseek-coder:6.7b # Efficient"
        echo "  ollama pull qwen2.5-coder:14b  # High quality"
        echo ""

        # On Raspberry Pi, suggest smaller models
        if [[ "$IS_RPI" == "true" ]]; then
            log_warning "On Raspberry Pi, use smaller models:"
            echo "  ollama pull codellama:7b"
            echo "  ollama pull phi:latest"
        fi
    else
        log_error "Ollama installation failed"
        return 1
    fi
}

# Install Claude Code CLI
install_claude() {
    log_info "Installing Claude Code CLI..."

    if ! command -v npm &> /dev/null; then
        install_nodejs
    fi

    sudo npm install -g @anthropic-ai/claude-code

    if command -v claude &> /dev/null; then
        log_success "Claude Code CLI installed"
        log_info "Set ANTHROPIC_API_KEY environment variable to use"
    else
        log_warning "Claude Code CLI may require additional setup"
    fi
}

# Setup Ralph
setup_ralph() {
    local install_dir="${1:-$PWD}"

    log_info "Setting up Ralph in $install_dir..."

    # Create directory structure
    mkdir -p "$install_dir/.ralph-scripts"
    mkdir -p "$install_dir/templates"

    # Copy or download ralph.sh
    if [[ -f "ralph.sh" ]]; then
        cp ralph.sh "$install_dir/"
    else
        curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/ralph.sh -o "$install_dir/ralph.sh"
    fi

    chmod +x "$install_dir/ralph.sh"

    # Create default config
    cat > "$install_dir/.ralph-scripts/ralph-config.json" << 'EOF'
{
    "defaultAgent": "gemini",
    "maxIterations": 20,
    "agents": {
        "ollama": {
            "endpoint": "http://localhost:11434/api/chat",
            "defaultModel": "codellama:13b"
        }
    },
    "git": {
        "autoCommit": true,
        "commitPrefix": "ralph:"
    }
}
EOF

    # Create example task
    cat > "$install_dir/templates/RALPH_TASK_example.md" << 'EOF'
---
task: Build REST API
test_command: npm test
---

# Task: REST API

Build a simple REST API with the following endpoints.

## Success Criteria

1. [ ] GET /health returns 200 OK
2. [ ] POST /users creates a new user
3. [ ] GET /users/:id returns user by ID
4. [ ] All tests pass

## Context

- Use Express.js or your preferred framework
- Include basic error handling
- Write unit tests for each endpoint
EOF

    log_success "Ralph setup complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. cd $install_dir"
    echo "  2. Create RALPH_TASK.md with your task"
    echo "  3. Run: ./ralph.sh"
    echo ""
}

# Show help
show_help() {
    cat << 'EOF'

Ralph for Linux - Installation Script

USAGE:
  ./install.sh [options]

OPTIONS:
  --agent <name>    Install specific agent:
                      gemini   - Google Gemini CLI
                      ollama   - Ollama local models
                      claude   - Claude Code CLI
  --all             Install all available agents
  --deps-only       Only install system dependencies
  --setup           Setup Ralph in current directory
  --help            Show this help

EXAMPLES:
  ./install.sh                    # Interactive installation
  ./install.sh --agent gemini     # Install Gemini CLI only
  ./install.sh --agent ollama     # Install Ollama only
  ./install.sh --all              # Install all agents
  ./install.sh --setup            # Setup Ralph files only

REMOTE INSTALLATION:
  curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash

SUPPORTED SYSTEMS:
  - Ubuntu 20.04+
  - Debian 11+
  - Raspberry Pi OS (Bookworm)
  - Fedora 38+
  - Arch Linux

EOF
}

# Interactive menu
interactive_menu() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "  Ralph for Linux - Installer"
    echo -e "${CYAN}============================================${NC}"
    echo ""
    echo "  System: $OS_NAME"
    echo "  Arch:   $ARCH"
    [[ "$IS_RPI" == "true" ]] && echo "  Device: $RPI_MODEL"
    echo ""
    echo "  1) Install Gemini CLI (recommended, free)"
    echo "  2) Install Ollama (local models)"
    echo "  3) Install Claude Code CLI"
    echo "  4) Install all agents"
    echo "  5) Setup Ralph only (no agents)"
    echo "  6) Exit"
    echo ""
    read -p "  Choose option [1-6]: " choice

    case $choice in
        1)
            install_dependencies
            install_gemini
            setup_ralph
            ;;
        2)
            install_dependencies
            install_ollama
            setup_ralph
            ;;
        3)
            install_dependencies
            install_claude
            setup_ralph
            ;;
        4)
            install_dependencies
            install_gemini
            install_ollama
            install_claude
            setup_ralph
            ;;
        5)
            install_dependencies
            setup_ralph
            ;;
        6)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            log_error "Invalid option"
            exit 1
            ;;
    esac
}

# =============================================================================
# Main
# =============================================================================

detect_os
check_root

# Parse arguments
AGENT=""
ALL_AGENTS="false"
DEPS_ONLY="false"
SETUP_ONLY="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --agent)
            AGENT="$2"
            shift 2
            ;;
        --all)
            ALL_AGENTS="true"
            shift
            ;;
        --deps-only)
            DEPS_ONLY="true"
            shift
            ;;
        --setup)
            SETUP_ONLY="true"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Execute based on arguments
if [[ "$DEPS_ONLY" == "true" ]]; then
    install_dependencies
    exit 0
fi

if [[ "$SETUP_ONLY" == "true" ]]; then
    setup_ralph
    exit 0
fi

if [[ -n "$AGENT" ]]; then
    install_dependencies
    case $AGENT in
        gemini) install_gemini ;;
        ollama) install_ollama ;;
        claude) install_claude ;;
        *)
            log_error "Unknown agent: $AGENT"
            exit 1
            ;;
    esac
    setup_ralph
    exit 0
fi

if [[ "$ALL_AGENTS" == "true" ]]; then
    install_dependencies
    install_gemini
    install_ollama
    install_claude
    setup_ralph
    exit 0
fi

# No arguments - run interactive menu
interactive_menu
