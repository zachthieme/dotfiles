#!/bin/bash
# Installation script for refactored dotfiles structure

set -euo pipefail # Exit on error, unset variable, or failure anywhere in a pipeline

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

NIX_FLAGS=(--extra-experimental-features nix-command --extra-experimental-features flakes)

# --- Parse Arguments ---

FLAKE_UPDATE=false
for arg in "$@"; do
  case $arg in
    --flake-update|-f) FLAKE_UPDATE=true ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --flake-update, -f  Update ALL flake.lock inputs (nixpkgs, home-manager,"
      echo "                      and the personal tools pike/tick/wen/grove) before"
      echo "                      rebuilding. Shows a diff and asks before continuing."
      echo "  --help, -h          Show this help message"
      echo ""
      echo "Without -f the committed flake.lock is used as-is (reproducible rebuild)."
      echo ""
      echo "To update only the personal tools without touching other inputs:"
      echo "  nix flake update pike tick wen grove"
      echo "  ./install.sh"
      exit 0
      ;;
  esac
done

# --- Helper Functions ---

log() { echo "=== $1 ==="; }
die() { echo "Error: $1" >&2; exit 1; }

# True if we can run sudo — non-interactively (cached/passwordless/root) or by
# validating once on a tty. Lets optional root-only steps (trusted-users, chsh)
# be skipped with a warning instead of aborting the whole install: standalone
# Home Manager needs no root at all.
have_sudo() {
  sudo -n true 2>/dev/null && return 0
  [ -t 0 ] && sudo -v 2>/dev/null
}

source_nix_profile() {
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
}

install_nix() {
  log "Installing Determinate Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- add
  source_nix_profile
  command -v nix &>/dev/null || die "Nix installation failed. Restart shell and retry."
  echo "Nix installed successfully."
}

# Fetch host info from definitions.nix (sets HOST_EXISTS, HOST_ALLOWS_FLAKE_UPDATE)
# A failed flake evaluation is fatal and reported as such — it must NOT be
# conflated with "hostname not found" (that misdiagnosis sends you debugging
# definitions.nix when the real problem is a syntax error or bad input).
fetch_host_info() {
  local hostname=$1
  local result
  if ! result=$(nix "${NIX_FLAGS[@]}" eval --raw "$SCRIPT_DIR#lib.hosts" --apply "
    hosts: let host = hosts.\"$hostname\" or null;
    in
      if host == null
      then \"false false\"
      else \"true \" + (if host.allowFlakeUpdate then \"true\" else \"false\")
  "); then
    die "flake evaluation failed (see error above) — this is not a missing-host problem"
  fi

  HOST_EXISTS=${result% *}
  HOST_ALLOWS_FLAKE_UPDATE=${result#* }
}

show_available_hosts() {
  echo "Available hosts:"
  # -oE, not -oP: macOS ships BSD grep, which has no Perl-regex support
  nix "${NIX_FLAGS[@]}" eval --json "$SCRIPT_DIR#lib.hosts" --apply builtins.attrNames \
    2>/dev/null | grep -oE '"[^"]+"' | tr -d '"' | sed 's/^/  - /' || echo "  (could not list hosts)"
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

# Check whether a trusted-users line in the conf file names the user.
# POSIX character classes only — \s and \b are GNU extensions that BSD
# sed/grep on macOS silently fail to match (no error, just no match).
user_in_trusted() {
  local conf=$1 user=$2
  grep -E "^trusted-users[[:space:]]*=" "$conf" 2>/dev/null |
    grep -qE "(^|[[:space:]])${user}([[:space:]]|\$)"
}

# Add a user to trusted-users in the given conf file (create/append/extend),
# then verify the edit actually landed — a sed that matches nothing exits 0
append_trusted_user() {
  local conf=$1 user=$2
  if [ ! -f "$conf" ]; then
    echo "trusted-users = root ${user}" | sudo tee "$conf" >/dev/null
  elif grep -qE "^trusted-users[[:space:]]*=" "$conf" 2>/dev/null; then
    sudo sed -i.bak "s/^\(trusted-users[[:space:]]*=.*\)/\1 ${user}/" "$conf"
    sudo rm -f "${conf}.bak"
  else
    echo "trusted-users = root ${user}" | sudo tee -a "$conf" >/dev/null
  fi
  user_in_trusted "$conf" "$user" ||
    die "failed to add '${user}' to trusted-users in ${conf} — edit it manually"
}

configure_trusted_users() {
  local nix_conf="/etc/nix/nix.conf"
  local nix_custom_conf="/etc/nix/nix.custom.conf"
  local current_user
  current_user=$(whoami)

  # Ensure /etc/nix exists (should exist after Nix install, but be safe)
  if [ ! -d "/etc/nix" ]; then
    echo "Warning: /etc/nix directory not found, skipping trusted-users config"
    return 0
  fi

  # Check if user is already trusted (check both files)
  if user_in_trusted "$nix_conf" "$current_user" || \
     user_in_trusted "$nix_custom_conf" "$current_user"; then
    echo "User '$current_user' already in trusted-users"
    return 0
  fi

  # trusted-users is a binary-cache optimization, not a requirement. Without
  # sudo, skip it rather than let set -e kill the whole (rootless) install.
  if ! have_sudo; then
    echo "Warning: no sudo access — skipping trusted-users config."
    echo "  Caches still work but may warn. To enable later, add '$current_user'"
    echo "  to trusted-users in /etc/nix/nix.conf and restart the nix-daemon."
    return 0
  fi

  log "Configuring Nix trusted-users"
  echo "Adding '$current_user' to trusted-users for binary cache access..."

  # Prefer nix.custom.conf if nix.conf includes it (Determinate Nix pattern)
  # This file persists across nix.conf rewrites
  if grep -qE "^!?include[[:space:]]+.*nix\.custom\.conf" "$nix_conf" 2>/dev/null; then
    append_trusted_user "$nix_custom_conf" "$current_user"
  else
    append_trusted_user "$nix_conf" "$current_user"
  fi

  # Restart nix-daemon to apply changes
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Restarting nix-daemon..."
    sudo launchctl kickstart -k system/org.nixos.nix-daemon 2>/dev/null || \
      sudo launchctl kickstart -k system/systems.determinate.nix-daemon 2>/dev/null || \
      echo "Warning: Could not restart nix-daemon. Restart manually or reboot."
  else
    if command -v systemctl &>/dev/null && systemctl is-active --quiet nix-daemon 2>/dev/null; then
      echo "Restarting nix-daemon..."
      sudo systemctl restart nix-daemon ||
        echo "Warning: nix-daemon restart failed. Restart it manually to apply trusted-users."
    fi
  fi

  echo "trusted-users configured successfully"
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

ARCHITECTURE=$(uname -m)
OS=$(uname -s)
NIX_SYSTEM=$(get_nix_system "$ARCHITECTURE" "$OS")

# Bare `hostname` can return an FQDN (cortex.local, cortex.lan) depending on
# DHCP/mDNS state — on a fresh machine, before nix-darwin has pinned the
# hostname, that breaks host lookup on the exact run where bootstrap matters.
# Prefer the short name; host keys in definitions.nix are short names.
if [[ "$OS" == "Darwin" ]]; then
  HOSTNAME=$(scutil --get LocalHostName 2>/dev/null || hostname -s 2>/dev/null || uname -n)
else
  HOSTNAME=$(hostname -s 2>/dev/null || cat /etc/hostname 2>/dev/null || uname -n)
fi
[ -z "$HOSTNAME" ] && die "Failed to detect hostname. Set HOSTNAME environment variable."

log "Dotfiles Installation"
echo "Detected:"
echo "  Host: $HOSTNAME"
echo "  Architecture: $ARCHITECTURE"
echo "  System: $NIX_SYSTEM"

fetch_host_info "$HOSTNAME"
if [ "$HOST_EXISTS" = false ]; then
  echo "Error: Hostname '$HOSTNAME' not found in hosts/definitions.nix"
  echo ""
  show_available_hosts
  echo ""
  die "Add your hostname to hosts/definitions.nix"
fi
mkdir -p "$HOME/Pictures/screenshots"

# --- Flake Update (if requested) ---

if [ "$FLAKE_UPDATE" = true ] && [ "$HOST_ALLOWS_FLAKE_UPDATE" = false ]; then
  echo "Error: host '$HOSTNAME' pins flake.lock (allowFlakeUpdate = false in definitions.nix)."
  echo ""
  echo "Update the lock on a dev machine first:"
  echo "  ./install.sh -f        # on dev — updates, rebuilds, verifies"
  echo "  jj commit && jj git push"
  echo ""
  echo "Then apply the committed lock here:"
  echo "  jj git fetch && ./install.sh"
  die "flake update refused on '$HOSTNAME'"
fi

if [ "$FLAKE_UPDATE" = true ]; then
  log "Updating flake.lock"
  # The user explicitly asked for an update — a failure must not silently
  # degrade into a rebuild of the stale lock
  # --flake is required: `nix flake update` treats positional args as INPUT
  # names, so `flake update "$SCRIPT_DIR"` silently updates nothing (the path
  # matches no input), exits 0, and this `|| die` never fires — the user thinks
  # the lock updated when it didn't.
  nix "${NIX_FLAGS[@]}" flake update --flake "$SCRIPT_DIR" ||
    die "flake update failed — fix the error above or rerun without -f to use the committed lock"
  echo "Flake inputs updated successfully"
  echo ""
  echo "Changed inputs (review before continuing):"
  git -C "$SCRIPT_DIR" diff --stat flake.lock 2>/dev/null || true
  echo ""
  read -p "Continue with rebuild? [Y/n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Aborting. Run 'jj restore flake.lock' to revert."
    exit 0
  fi
fi

# --- Configure Nix trusted-users (before rebuild to avoid warnings) ---

configure_trusted_users

# --- OS-Specific Setup ---

if [[ "$OS" == "Darwin" ]]; then
  # Install Homebrew first (needed by darwin config)
  if ! command -v brew &>/dev/null; then
    log "Installing Homebrew"
    # Download-then-run, never `bash -c "$(curl ...)"`: a failed curl there
    # yields `bash -c ""`, which exits 0 and masks the failure — the script
    # then dies confusingly at `brew shellenv`. NONINTERACTIVE avoids the
    # installer's RETURN prompt hanging a headless run.
    brew_installer=$(mktemp)
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$brew_installer" \
      || die "Failed to download the Homebrew installer"
    NONINTERACTIVE=1 /bin/bash "$brew_installer" || { rm -f "$brew_installer"; die "Homebrew installation failed"; }
    rm -f "$brew_installer"
    # Add Homebrew to PATH for this session
    if [[ "$ARCHITECTURE" == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    command -v brew &>/dev/null || die "Homebrew installed but 'brew' is not on PATH"
  fi

  echo "Applying nix-darwin configuration..."
  # On a fresh machine darwin-rebuild doesn't exist until nix-darwin has
  # activated once — bootstrap it from the nix-darwin flake in that case
  if command -v darwin-rebuild &>/dev/null; then
    DARWIN_REBUILD=(darwin-rebuild)
  else
    log "Bootstrapping nix-darwin (first install)"
    # Explicit github ref — the bare "nix-darwin" registry alias isn't
    # guaranteed to exist on a fresh install
    DARWIN_REBUILD=(nix "${NIX_FLAGS[@]}" run github:nix-darwin/nix-darwin#darwin-rebuild --)
  fi
  if ! sudo "${DARWIN_REBUILD[@]}" switch --flake "$SCRIPT_DIR#$HOSTNAME"; then
    echo ""
    if command -v darwin-rebuild &>/dev/null; then
      echo "To roll back to the previous generation:"
      echo "  sudo darwin-rebuild switch --rollback"
    else
      echo "This was the first install — nix-darwin never activated, so there is"
      echo "no generation to roll back to. Fix the error above and re-run ./install.sh."
    fi
    die "darwin-rebuild failed"
  fi
else
  if ! command -v home-manager &>/dev/null; then
    echo "Installing home-manager..."
    nix "${NIX_FLAGS[@]}" profile add nixpkgs#home-manager || die "Failed to install home-manager"
  fi

  echo "Applying Home Manager configuration..."
  if ! home-manager switch -b backup --flake "$SCRIPT_DIR#$HOSTNAME"; then
    echo ""
    echo "To roll back: list generations, then run the chosen generation's own"
    echo "activate script (there is no 'home-manager activate' subcommand):"
    echo "  home-manager generations"
    echo "  /nix/store/<hash>-home-manager-generation/activate"
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

  # Change default shell to fish (if not already)
  FISH_PATH="$HOME/.local/state/nix/profiles/home-manager/home-path/bin/fish"
  TARGET_USER=${USER:-$(id -un)}
  if command -v getent &>/dev/null; then
    CURRENT_SHELL=$(getent passwd "$TARGET_USER" | cut -d: -f7 || true)
  else
    CURRENT_SHELL=${SHELL:-}
  fi

  if [ -f "$FISH_PATH" ] && [[ "$(basename "$CURRENT_SHELL")" != "fish" ]]; then
    if have_sudo; then
      log "Changing default shell to fish"
      # Add fish to /etc/shells if not already present
      if ! grep -qxF "$FISH_PATH" /etc/shells 2>/dev/null; then
        echo "Adding fish to /etc/shells..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
      fi
      # Change default shell
      echo "Setting fish as default shell..."
      sudo chsh -s "$FISH_PATH" "$TARGET_USER"
      echo "Default shell changed to fish. Log out and back in to use it."
    else
      log "Skipping default-shell change (no sudo)"
      echo "To make fish your login shell later, run:"
      echo "  echo '$FISH_PATH' | sudo tee -a /etc/shells"
      echo "  sudo chsh -s '$FISH_PATH' '$TARGET_USER'"
    fi
  fi
fi

log "Installation complete"
echo "Restart your terminal for changes to take effect."
