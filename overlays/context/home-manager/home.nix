# Home-specific Home Manager configuration
{ pkgs, config, ... }:

{
  imports = [
    ../../../home-manager/base.nix
  ];

  # Home-specific shell abbreviations
  programs.fish.shellAbbrs = {
    # Override abbreviations for home machines here
  };

  home.file = {
    # Home-specific dotfiles
  };

  home.packages = with pkgs; [
    # opencode - installed via activation script
  ];

  # Install Claude Code CLI on home machines only (skip if already installed)
  # Note: Uses official installer since claude-code isn't in nixpkgs yet
  # To upgrade, run: curl -fsSL https://claude.ai/install.sh | bash
  home.activation.installClaudeCode = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    CLAUDE_BIN="${config.home.homeDirectory}/.local/bin/claude"

    if [ -f "$CLAUDE_BIN" ]; then
      echo "Claude Code CLI already installed (version: $($CLAUDE_BIN --version 2>/dev/null || echo 'unknown'))"
      echo "Claude Code CLI already installed, skipping. Run 'install.sh --upgrade' to upgrade."
    else
      echo "Installing Claude Code CLI..."
      INSTALL_SCRIPT="/tmp/claude-install-$$.sh"

      if ! $DRY_RUN_CMD ${pkgs.curl}/bin/curl \
        --fail --silent --show-error --location \
        --max-time 30 \
        https://claude.ai/install.sh -o "$INSTALL_SCRIPT"; then
        echo "ERROR: Failed to download Claude Code installer" >&2
        $DRY_RUN_CMD rm -f "$INSTALL_SCRIPT"
        exit 1
      fi

      # Verify script looks valid
      if [ ! -s "$INSTALL_SCRIPT" ] || ! head -1 "$INSTALL_SCRIPT" | grep -q '^#!'; then
        echo "ERROR: Downloaded installer appears invalid" >&2
        $DRY_RUN_CMD rm -f "$INSTALL_SCRIPT"
        exit 1
      fi

      $DRY_RUN_CMD chmod +x "$INSTALL_SCRIPT"

      if ! PATH="${pkgs.curl}/bin:${pkgs.gzip}/bin:${pkgs.gnutar}/bin:$PATH" \
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash "$INSTALL_SCRIPT"; then
        echo "ERROR: Claude Code installation failed" >&2
        $DRY_RUN_CMD rm -f "$INSTALL_SCRIPT"
        exit 1
      fi

      $DRY_RUN_CMD rm -f "$INSTALL_SCRIPT"
      echo "Claude Code CLI installed successfully"
    fi
  '';

  # Install OpenCode CLI on home machines only (skip if already installed)
  # Note: Uses official installer since opencode isn't in nixpkgs yet
  # To upgrade, run: curl -fsSL https://opencode.ai/install | bash
  home.activation.installOpenCode = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    OPENCODE_BIN="${config.home.homeDirectory}/.opencode/bin/opencode"

    if [ -f "$OPENCODE_BIN" ]; then
      echo "OpenCode CLI already installed (version: $($OPENCODE_BIN --version 2>/dev/null || echo 'unknown'))"
      echo "OpenCode CLI already installed, skipping. Run 'install.sh --upgrade' to upgrade."
    else
      echo "Installing OpenCode CLI..."
      INSTALL_SCRIPT="/tmp/opencode-install-$$.sh"

      if ! $DRY_RUN_CMD ${pkgs.curl}/bin/curl \
        --fail --silent --show-error --location \
        --max-time 30 \
        https://opencode.ai/install -o "$INSTALL_SCRIPT"; then
        echo "ERROR: Failed to download OpenCode installer" >&2
        $DRY_RUN_CMD rm -f "$INSTALL_SCRIPT"
        exit 1
      fi

      # Verify script looks valid
      if [ ! -s "$INSTALL_SCRIPT" ] || ! head -1 "$INSTALL_SCRIPT" | grep -q '^#!'; then
        echo "ERROR: Downloaded installer appears invalid" >&2
        $DRY_RUN_CMD rm -f "$INSTALL_SCRIPT"
        exit 1
      fi

      $DRY_RUN_CMD chmod +x "$INSTALL_SCRIPT"

      # Create a temp .zshrc so installer doesn't fail (it needs a shell config to modify)
      # We manage PATH via fish.nix, so this is just to satisfy the installer
      TEMP_ZSHRC="${config.home.homeDirectory}/.zshrc"
      CREATED_ZSHRC=""
      if [ ! -f "$TEMP_ZSHRC" ]; then
        $DRY_RUN_CMD touch "$TEMP_ZSHRC"
        CREATED_ZSHRC="1"
      fi

      if ! SHELL=/bin/zsh PATH="${pkgs.curl}/bin:${pkgs.gzip}/bin:${pkgs.gnutar}/bin:${pkgs.unzip}/bin:$PATH" \
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash "$INSTALL_SCRIPT"; then
        echo "ERROR: OpenCode installation failed" >&2
        # Clean up temp .zshrc if we created it
        if [ -n "$CREATED_ZSHRC" ] && [ -f "$TEMP_ZSHRC" ]; then
          $DRY_RUN_CMD rm -f "$TEMP_ZSHRC"
        fi
        $DRY_RUN_CMD rm -f "$INSTALL_SCRIPT"
        exit 1
      fi

      # Clean up temp .zshrc if we created it
      if [ -n "$CREATED_ZSHRC" ] && [ -f "$TEMP_ZSHRC" ]; then
        $DRY_RUN_CMD rm -f "$TEMP_ZSHRC"
      fi
      $DRY_RUN_CMD rm -f "$INSTALL_SCRIPT"
      echo "OpenCode CLI installed successfully"
    fi
  '';
}
