#!/bin/bash
# Installation script for refactored dotfiles structure

# Get the directory of this script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Determine the hostname and architecture
HOSTNAME=$(hostname)
ARCHITECTURE=$(uname -m)

# Determine configuration name
if [[ "$HOSTNAME" == "zthieme"* ]]; then
  CONFIG_NAME="zthieme34911"
elif [[ "$ARCHITECTURE" == "arm64" ]]; then
  CONFIG_NAME="cortex"
else
  CONFIG_NAME="malv2"
fi

# Export for nix detection
export HOSTNAME
export NIX_SYSTEM=$([ "$ARCHITECTURE" == "arm64" ] && echo "aarch64-darwin" || echo "x86_64-darwin")

echo "=== Dotfiles Installation ==="
echo "Detected:"
echo "  Host: $HOSTNAME"
echo "  Architecture: $ARCHITECTURE"
echo "  System: $NIX_SYSTEM"
echo "  Configuration: $CONFIG_NAME"

# Create screenshots directory if it doesn't exist
mkdir -p ~/Pictures/screenshots/

# Install nix-darwin if not already installed
# if ! command -v darwin-rebuild &>/dev/null; then
#   echo "Installing nix-darwin..."
#   nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
#   ./result/bin/darwin-installer
# fi

# Apply the configuration
echo "Applying nix-darwin configuration..."
echo "Running: darwin-rebuild switch --flake $SCRIPT_DIR#$CONFIG_NAME"
sudo darwin-rebuild switch --flake "$SCRIPT_DIR#$CONFIG_NAME"

# Install doom-emacs if not already installed
if ! command -v "$HOME/.config/emacs/bin/doom" &>/dev/null; then
  echo "Installing Doom Emacs..."
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install
fi

# Install homebrew if not already installed
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installation complete!"
echo "You may need to restart your terminal or computer for all changes to take effect."
