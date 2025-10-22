#!/bin/bash
# Installation script for refactored dotfiles structure

# Get the directory of this script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Determine the hostname, architecture, and operating system
HOSTNAME=$(hostname)
ARCHITECTURE=$(uname -m)
OS=$(uname -s)

if [[ "$OS" == "Darwin" ]]; then
  # Determine configuration name for macOS
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

else
  # Linux setup using Home Manager
  CONFIG_NAME="srv722852"
  export HOSTNAME
  export NIX_SYSTEM="x86_64-linux"

  echo "=== Dotfiles Installation ==="
  echo "Detected:"
  echo "  Host: $HOSTNAME"
  echo "  Architecture: $ARCHITECTURE"
  echo "  System: $NIX_SYSTEM"
  echo "  Configuration: $CONFIG_NAME"

  mkdir -p ~/Pictures/screenshots/

  if ! command -v home-manager &>/dev/null; then
    echo "home-manager not found; installing..."
    if ! nix --extra-experimental-features "nix-command flakes" \
      profile install nixpkgs#home-manager; then
      echo "Failed to install home-manager."
      echo "Ensure that the nix-command and flakes experimental features are enabled."
      exit 1
    fi
  fi

  echo "Applying Home Manager configuration..."
  home-manager switch --flake "$SCRIPT_DIR#$CONFIG_NAME"

  if ! command -v "$HOME/.config/emacs/bin/doom" &>/dev/null; then
    echo "Installing Doom Emacs..."
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install
  fi
fi

echo "Installation complete!"
echo "You may need to restart your terminal or computer for all changes to take effect."
