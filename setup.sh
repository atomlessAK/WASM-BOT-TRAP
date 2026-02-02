#!/bin/bash
# setup.sh - One-command setup for WASM Bot Trap development
#
# Usage: ./setup.sh
#
# This script installs all required dependencies for macOS:
#   - Homebrew (if missing)
#   - Rust/Cargo (via rustup)
#   - wasm32-wasip1 target
#   - Fermyon Spin CLI
#   - cargo-watch (for file watching)
#
# After setup, run: make dev

set -e

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
NC="\033[0m"

info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║     WASM Bot Trap - Development Setup             ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"

#--------------------------
# Check macOS
#--------------------------
if [[ "$(uname)" != "Darwin" ]]; then
    warn "This script is designed for macOS. You may need to adapt for your OS."
    warn "Linux users: Replace Homebrew commands with your package manager."
fi

#--------------------------
# Homebrew
#--------------------------
if command -v brew &> /dev/null; then
    success "Homebrew already installed"
else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    success "Homebrew installed"
fi

#--------------------------
# Rust / Cargo
#--------------------------
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version | cut -d' ' -f2)
    success "Rust already installed (v$RUST_VERSION)"
else
    info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    success "Rust installed"
fi

# Ensure cargo is in PATH for this session
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

#--------------------------
# WASM target
#--------------------------
if rustup target list --installed | grep -q "wasm32-wasip1"; then
    success "wasm32-wasip1 target already installed"
else
    info "Adding wasm32-wasip1 target..."
    rustup target add wasm32-wasip1
    success "wasm32-wasip1 target installed"
fi

#--------------------------
# Fermyon Spin
#--------------------------
if command -v spin &> /dev/null; then
    SPIN_VERSION=$(spin --version | head -1)
    success "Spin already installed ($SPIN_VERSION)"
else
    info "Installing Fermyon Spin..."
    curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
    sudo mv spin /usr/local/bin/
    success "Spin installed"
fi

#--------------------------
# cargo-watch
#--------------------------
if command -v cargo-watch &> /dev/null; then
    success "cargo-watch already installed"
else
    info "Installing cargo-watch (for file watching)..."
    cargo install cargo-watch
    success "cargo-watch installed"
fi

#--------------------------
# Verify installation
#--------------------------
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 Setup complete! Installed versions:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

echo -n "  Rust:         "
rustc --version 2>/dev/null || echo "not found"

echo -n "  Cargo:        "
cargo --version 2>/dev/null || echo "not found"

echo -n "  WASM target:  "
if rustup target list --installed | grep -q "wasm32-wasip1"; then
    echo "wasm32-wasip1 ✓"
else
    echo "not installed"
fi

echo -n "  Spin:         "
spin --version 2>/dev/null | head -1 || echo "not found"

echo -n "  cargo-watch:  "
cargo-watch --version 2>/dev/null || echo "not found"

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 Ready to go! Run these commands:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo "  make dev      # Start dev server with file watching"
echo "  make run      # Build once and run (no watching)"
echo "  make test     # Run tests"
echo "  make help     # Show all commands"
echo ""
echo -e "${YELLOW}📊 Dashboard: http://127.0.0.1:3000/dashboard/index.html${NC}"
echo ""
