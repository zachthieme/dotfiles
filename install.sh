#!/bin/bash
# Installation script for refactored dotfiles structure

set -e  # Exit on error

export NIX_CONFIG="experimental-features = nix-command flakes"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# --- Parse Arguments ---

UPGRADE_TOOLS=false
for arg in "$@"; do
  case $arg in
    --upgrade|-u) UPGRADE_TOOLS=true ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --upgrade, -u    Upgrade claude and opencode CLI tools (home machines only)"
      echo "  --help, -h       Show this help message"
      exit 0
      ;;
  esac
done

# --- Helper Functions ---

log() { echo "=== $1 ==="; }
die() { echo "Error: $1" >&2; exit 1; }

upgrade_tools() {
  log "Upgrading CLI tools"
  echo "Upgrading Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
  echo "Upgrading OpenCode..."
  curl -fsSL https://opencode.ai/install | bash
}

source_nix_profile() {
  [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] && \
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
}

install_nix() {
  log "Installing Determinate Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  source_nix_profile
  command -v nix &>/dev/null || die "Nix installation failed. Restart shell and retry."
  echo "Nix installed successfully."
}

# Fetch host info from definitions.nix (sets HOST_EXISTS and IS_WORK)
fetch_host_info() {
  local hostname=$1
  local info
  info=$(nix eval --raw --impure --expr "
    let
      flake = builtins.getFlake \"$SCRIPT_DIR\";
      hosts = flake.outputs.hosts or {};
      exists = builtins.hasAttr \"$hostname\" hosts;
      host = hosts.\"$hostname\" or {};
    in
      if exists then \"exists:\" + (if host.isWork or false then \"work\" else \"home\")
      else \"missing\"
  " 2>/dev/null) || info="missing"

  if [ "$info" = "missing" ]; then
    HOST_EXISTS=false
    IS_WORK=false
  else
    HOST_EXISTS=true
    IS_WORK=$( [ "$info" = "exists:work" ] && echo true || echo false )
  fi
}

show_available_hosts() {
  echo "Available hosts:"
  nix eval --json --impure --expr "builtins.attrNames ((builtins.getFlake \"$SCRIPT_DIR\").outputs.hosts or {})" \
    2>/dev/null | grep -oP '(?<=")[\w-]+(?=")' | sed 's/^/  - /'
}

get_nix_system() {
  local arch=$1 os=$2
  case "$os-$arch" in
    Darwin-arm64)   echo "aarch64-darwin" ;;
    Darwin-x86_64)  echo "x86_64-darwin" ;;
    Linux-aarch64)  echo "aarch64-linux" ;;
    *)              echo "x86_64-linux" ;;
  esac
}

# --- Nix Installation Check ---

if ! command -v nix &>/dev/null; then
  source_nix_profile
  if ! command -v nix &>/dev/null; then
    echo "Nix is not installed."
    read -p "Install Determinate Nix? [Y/n] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Nn]$ ]] && die "Nix is required"
    install_nix
  fi
fi

# --- Detection ---

HOSTNAME=$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || uname -n)
[ -z "$HOSTNAME" ] && die "Failed to detect hostname. Set HOSTNAME environment variable."
ARCHITECTURE=$(uname -m)
OS=$(uname -s)
NIX_SYSTEM=$(get_nix_system "$ARCHITECTURE" "$OS")

export HOSTNAME NIX_SYSTEM

log "Dotfiles Installation"
echo "Detected:"
echo "  Host: $HOSTNAME"
echo "  Architecture: $ARCHITECTURE"
echo "  System: $NIX_SYSTEM"

fetch_host_info "$HOSTNAME"
if [ "$HOST_EXISTS" = false ]; then
  echo "Error: Hostname '$HOSTNAME' not found in modules/hosts/definitions.nix"
  echo ""
  show_available_hosts
  echo ""
  die "Add your hostname to modules/hosts/definitions.nix"
fi
mkdir -p ~/Pictures/screenshots/

# --- OS-Specific Setup ---

if [[ "$OS" == "Darwin" ]]; then
  # Install Homebrew first (needed by darwin config)
  if ! command -v brew &>/dev/null; then
    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for this session
    if [[ "$ARCHITECTURE" == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  echo "Applying nix-darwin configuration..."
  if ! sudo darwin-rebuild switch --flake "$SCRIPT_DIR#$HOSTNAME"; then
    echo ""
    echo "To rollback to previous generation:"
    echo "  sudo darwin-rebuild switch --rollback"
    die "darwin-rebuild failed"
  fi
else
  if ! command -v home-manager &>/dev/null; then
    echo "Installing home-manager..."
    nix profile add nixpkgs#home-manager || die "Failed to install home-manager"
  fi

  echo "Applying Home Manager configuration..."
  if ! home-manager switch -b backup --flake "$SCRIPT_DIR#$HOSTNAME"; then
    echo ""
    echo "To rollback to previous generation:"
    echo "  home-manager generations"
    echo "  home-manager activate <path-to-generation>"
    die "home-manager failed"
  fi

  # Configure bash PATH
  HM_MARKER="# Home Manager PATH setup"
  if ! grep -q "$HM_MARKER" "$HOME/.bashrc" 2>/dev/null; then
    log "Configuring Bash for Home Manager"
    cat >> "$HOME/.bashrc" << 'EOF'

# Home Manager PATH setup
if [ -d "$HOME/.local/state/nix/profiles/home-manager/home-path/bin" ]; then
  export PATH="$HOME/.local/state/nix/profiles/home-manager/home-path/bin:$PATH"
fi
if [ -f "$HOME/.local/state/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh" ]; then
  . "$HOME/.local/state/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh"
fi
EOF
  fi

  # Shell change reminder (portable: getent on Linux, dscl on macOS, fallback to $SHELL)
  FISH_PATH="$HOME/.local/state/nix/profiles/home-manager/home-path/bin/fish"
  if command -v getent &>/dev/null; then
    CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
  elif command -v dscl &>/dev/null; then
    CURRENT_SHELL=$(dscl . -read /Users/"$USER" UserShell | awk '{print $2}')
  else
    CURRENT_SHELL="$SHELL"
  fi
  if [ -f "$FISH_PATH" ] && [ "$CURRENT_SHELL" != "$FISH_PATH" ]; then
    log "ACTION REQUIRED: Change Default Shell"
    echo "Current shell: $CURRENT_SHELL"
    echo "Run:"
    echo "  echo \"$FISH_PATH\" | sudo tee -a /etc/shells"
    echo "  chsh -s \"$FISH_PATH\""
  fi
fi

# --- Upgrade Tools (if requested, home machines only) ---

if [ "$UPGRADE_TOOLS" = true ]; then
  if [ "$IS_WORK" = true ]; then
    echo "Skipping tool upgrades on work machine"
  else
    upgrade_tools
  fi
fi

log "Installation complete"
echo "Restart your terminal for changes to take effect."
