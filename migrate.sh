#!/bin/bash
# Migration script to transition from the old to the new dotfiles structure

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

echo "=== Dotfiles Migration Script ==="
echo "This script will help transition from the old structure to the new one."
echo "It will also remove duplicated configuration files that are no longer needed."

# Detect the current system
HOSTNAME=$(hostname)
ARCHITECTURE=$(uname -m)

# Determine configuration name
if [[ "$HOSTNAME" == "zthieme"* ]]; then
  CONFIG_NAME="zthieme34911"
elif [[ "$ARCHITECTURE" == "arm64" ]]; then
  CONFIG_NAME="cortex-m4"
else
  CONFIG_NAME="cortex-intel"
fi

# Export for nix detection
export HOSTNAME
export NIX_SYSTEM=$([ "$ARCHITECTURE" == "arm64" ] && echo "aarch64-darwin" || echo "x86_64-darwin")

echo "Detected:"
echo "  - Host: $HOSTNAME"
echo "  - Architecture: $ARCHITECTURE"
echo "  - System: $NIX_SYSTEM"
echo "  - Configuration: $CONFIG_NAME"
echo

# Make sure nix and nix-darwin are installed
if ! command -v nix &>/dev/null; then
  echo "Nix is not installed. Please install Nix first."
  exit 1
fi

if ! command -v darwin-rebuild &>/dev/null; then
  echo "nix-darwin is not installed. Please install nix-darwin first."
  exit 1
fi

# Check that all required directories exist
echo "Checking required directories..."
for dir in "base" "home-manager" "hosts/$CONFIG_NAME" "overlays/arch" "overlays/context"; do
  if [ ! -d "$SCRIPT_DIR/$dir" ]; then
    echo "Error: Required directory $dir does not exist."
    exit 1
  fi
done

# Function to set file permissions
fix_permissions() {
  echo "Setting correct permissions on executable files..."
  chmod +x "$SCRIPT_DIR/install.sh"
  chmod +x "$SCRIPT_DIR/migrate.sh"
}

# Apply the new configuration
apply_config() {
  echo "Applying the new configuration using nix-darwin..."
  echo "Running: darwin-rebuild switch --flake $SCRIPT_DIR#$CONFIG_NAME"
  
  # Use the environment variables for auto-detection
  darwin-rebuild switch --flake "$SCRIPT_DIR"#"$CONFIG_NAME"
}

# Main menu
echo "What would you like to do?"
echo "1. Apply the new configuration"
echo "2. Fix file permissions"
echo "3. Clean up old directories and duplicate files"
echo "4. Exit"
read -p "Enter your choice (1-4): " choice

case $choice in
  1)
    apply_config
    ;;
  2)
    fix_permissions
    ;;
  3)
    echo "Cleaning up old directories and duplicate files..."
    echo "This will move old files to backup folders, not delete them."
    read -p "Continue? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
      # Create backup directory with timestamp
      BACKUP_DIR="$SCRIPT_DIR/backup/$(date +%Y%m%d_%H%M%S)"
      mkdir -p "$BACKUP_DIR"
      
      # Backup and remove duplicate flake files
      echo "Backing up redundant flake files..."
      for dir in "home" "work"; do
        if [ -f "$SCRIPT_DIR/$dir/flake.nix" ]; then
          mkdir -p "$BACKUP_DIR/$dir"
          cp "$SCRIPT_DIR/$dir/flake.nix" "$BACKUP_DIR/$dir/"
          echo "Backed up $dir/flake.nix"
        fi
      done
      
      # Backup old directories
      echo "Moving old directories to backup..."
      [ -d "$SCRIPT_DIR/home" ] && mv "$SCRIPT_DIR/home" "$BACKUP_DIR/home"
      [ -d "$SCRIPT_DIR/work" ] && mv "$SCRIPT_DIR/work" "$BACKUP_DIR/work"
      
      echo "All redundant files backed up to $BACKUP_DIR"
      echo "Cleanup completed successfully!"
    else
      echo "Cleanup canceled."
    fi
    ;;
  4)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting..."
    exit 1
    ;;
esac

echo
echo "Migration completed successfully!"
echo "You can now use ./install.sh for future updates."
echo
echo "Note: The refactored structure eliminates duplication by:"
echo "- Using a single flake.nix at the root"
echo "- Sharing common configuration in base/"
echo "- Using overlays for context-specific and architecture-specific settings"
echo "- Keeping only minimal machine-specific settings in hosts/"