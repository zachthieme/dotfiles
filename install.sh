#!/bin/bash
# Installation script for refactored dotfiles structure

# Get the directory of this script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Determine the hostname, architecture, and operating system
HOSTNAME=$(hostname)
ARCHITECTURE=$(uname -m)
OS=$(uname -s)

# Helper function to check if hostname exists in definitions.nix
check_hostname_exists() {
  local hostname=$1
  if ! nix eval --raw --impure --expr "
    let
      flake = builtins.getFlake \"$SCRIPT_DIR\";
      hosts = flake.outputs.hosts or {};
    in
      if builtins.hasAttr \"$hostname\" hosts
      then \"true\"
      else \"false\"
  " 2>/dev/null | grep -q "true"; then
    echo "Error: Hostname '$hostname' not found in modules/hosts/definitions.nix"
    echo ""
    echo "Available hosts:"
    nix eval --json --impure --expr "
      let
        flake = builtins.getFlake \"$SCRIPT_DIR\";
      in
        builtins.attrNames (flake.outputs.hosts or {})
    " 2>/dev/null | grep -oP '(?<=")[\w-]+(?=")' | sed 's/^/  - /'
    echo ""
    echo "Please add your hostname to modules/hosts/definitions.nix or use one of the above."
    exit 1
  fi
}

if [[ "$OS" == "Darwin" ]]; then
  # Use actual hostname as configuration name
  CONFIG_NAME="$HOSTNAME"

  # Export for nix detection
  export HOSTNAME
  export NIX_SYSTEM=$([ "$ARCHITECTURE" == "arm64" ] && echo "aarch64-darwin" || echo "x86_64-darwin")

  echo "=== Dotfiles Installation ==="
  echo "Detected:"
  echo "  Host: $HOSTNAME"
  echo "  Architecture: $ARCHITECTURE"
  echo "  System: $NIX_SYSTEM"
  echo "  Configuration: $CONFIG_NAME"

  # Check if hostname exists in definitions.nix
  check_hostname_exists "$CONFIG_NAME"

  # Create screenshots directory if it doesn't exist
  mkdir -p ~/Pictures/screenshots/

  # Apply the configuration
  echo "Applying nix-darwin configuration..."
  echo "Running: darwin-rebuild switch --flake $SCRIPT_DIR#$CONFIG_NAME"
  sudo darwin-rebuild switch --flake "$SCRIPT_DIR#$CONFIG_NAME"

  # Install homebrew if not already installed
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

else
  # Linux setup using Home Manager
  CONFIG_NAME="$HOSTNAME"
  export HOSTNAME
  export NIX_SYSTEM=$([ "$ARCHITECTURE" == "aarch64" ] && echo "aarch64-linux" || echo "x86_64-linux")

  echo "=== Dotfiles Installation ==="
  echo "Detected:"
  echo "  Host: $HOSTNAME"
  echo "  Architecture: $ARCHITECTURE"
  echo "  System: $NIX_SYSTEM"
  echo "  Configuration: $CONFIG_NAME"

  # Check if hostname exists in definitions.nix
  check_hostname_exists "$CONFIG_NAME"

  mkdir -p ~/Pictures/screenshots/

  # Source nix profile if not already in PATH
  if ! command -v nix &>/dev/null; then
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      echo "Sourcing nix profile..."
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    else
      echo "Error: nix is not installed or not in PATH."
      echo "Please install nix from https://nixos.org/download.html"
      exit 1
    fi
  fi

  if ! command -v home-manager &>/dev/null; then
    echo "home-manager not found; installing..."
    if ! nix --extra-experimental-features "nix-command flakes" \
      profile add nixpkgs#home-manager; then
      echo "Failed to install home-manager."
      echo "Ensure that the nix-command and flakes experimental features are enabled."
      exit 1
    fi
  fi

  echo "Applying Home Manager configuration..."
  home-manager switch --extra-experimental-features "nix-command flakes" --flake "$SCRIPT_DIR#$CONFIG_NAME"

  # Check if default shell is fish and remind user to change if needed
  CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
  FISH_PATH="$HOME/.nix-profile/bin/fish"
  if [ "$CURRENT_SHELL" != "$FISH_PATH" ] && command -v fish &>/dev/null; then
    echo ""
    echo "=== Shell Configuration Reminder ==="
    echo "Your default shell is currently: $CURRENT_SHELL"
    echo "To change your default shell to fish, run:"
    echo "  echo \"$FISH_PATH\" | sudo tee -a /etc/shells"
    echo "  chsh -s $FISH_PATH"
    echo ""
  fi
fi
echo "Installation complete!"
echo "You may need to restart your terminal or computer for all changes to take effect."
