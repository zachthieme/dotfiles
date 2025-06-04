#!/bin/bash
# Installation script for Linux systems

# Get the directory of this script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Determine the hostname and architecture
HOSTNAME=$(hostname)
ARCHITECTURE=$(uname -m)

# Determine configuration name
if [[ "$ARCHITECTURE" == "x86_64" ]]; then
  CONFIG_NAME="jayne"
else
  echo "Unsupported architecture: $ARCHITECTURE"
  exit 1
fi

# Export for nix detection
export HOSTNAME
export NIX_SYSTEM="x86_64-linux"

echo "=== Dotfiles Installation for Linux ==="
echo "Detected:"
echo "  Host: $HOSTNAME"
echo "  Architecture: $ARCHITECTURE"
echo "  System: $NIX_SYSTEM"
echo "  Configuration: $CONFIG_NAME"

# Check if Nix is installed
if ! command -v nix &>/dev/null; then
  echo "Installing Nix..."
  sh <(curl -L https://nixos.org/nix/install) --daemon

  # Source nix
  . /etc/profile.d/nix.sh
fi

# Apply the NixOS configuration
if [ -f /etc/nixos/configuration.nix ]; then
  echo "Applying NixOS configuration..."
  echo "Running: sudo nixos-rebuild switch --flake $SCRIPT_DIR#$CONFIG_NAME"
  sudo nixos-rebuild switch --flake "$SCRIPT_DIR#$CONFIG_NAME"
else
  echo "Warning: This doesn't appear to be a NixOS system."
  echo "You can still use home-manager standalone:"
  echo "home-manager switch --flake $SCRIPT_DIR#$CONFIG_NAME"

  # Install home-manager if not already installed
  if ! command -v home-manager &>/dev/null; then
    echo "Installing home-manager..."
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
  fi

  # Apply home-manager configuration
  echo "Applying home-manager configuration..."
  home-manager switch --flake "$SCRIPT_DIR#$CONFIG_NAME"
fi

# Install doom-emacs if not already installed
if ! command -v "$HOME/.config/emacs/bin/doom" &>/dev/null; then
  echo "Installing Doom Emacs..."
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install
fi

echo "Installation complete!"
echo "You may need to restart your system for all changes to take effect."
