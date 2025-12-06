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

  # Install/upgrade Claude Code CLI on home machines only
  # Note: Uses official installer since claude-code isn't in nixpkgs yet
  # Download script first, then run with required tools in PATH
  home.activation.installClaudeCode = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    CLAUDE_BIN="${config.home.homeDirectory}/.local/bin/claude"
    INSTALL_SCRIPT="/tmp/claude-install.sh"
    
    # Download the installer script
    echo "Downloading Claude Code installer..."
    $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh -o $INSTALL_SCRIPT
    
    # Make script executable and extract version info
    $DRY_RUN_CMD chmod +x $INSTALL_SCRIPT
    
    if [ -f "$CLAUDE_BIN" ]; then
      echo "Claude Code CLI found, checking for updates..."
      # Run installer which will handle version checking and upgrades
      PATH="${pkgs.curl}/bin:${pkgs.gzip}/bin:${pkgs.gnutar}/bin:$PATH" \
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash $INSTALL_SCRIPT
    else
      echo "Installing Claude Code CLI..."
      PATH="${pkgs.curl}/bin:${pkgs.gzip}/bin:${pkgs.gnutar}/bin:$PATH" \
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash $INSTALL_SCRIPT
    fi
    
    $DRY_RUN_CMD rm -f $INSTALL_SCRIPT
  '';

  # Install/upgrade OpenCode CLI on home machines only
  # Note: Uses official installer since opencode isn't in nixpkgs yet
  # Download script first, then run with required tools in PATH
  home.activation.installOpenCode = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    OPENCODE_BIN="${config.home.homeDirectory}/.local/bin/opencode"
    INSTALL_SCRIPT="/tmp/opencode-install.sh"
    
    # Download the installer script
    echo "Downloading OpenCode installer..."
    $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL https://opencode.ai/install.sh -o $INSTALL_SCRIPT
    
    # Make script executable and extract version info
    $DRY_RUN_CMD chmod +x $INSTALL_SCRIPT
    
    if [ -f "$OPENCODE_BIN" ]; then
      echo "OpenCode CLI found, checking for updates..."
      # Run installer which will handle version checking and upgrades
      PATH="${pkgs.curl}/bin:${pkgs.gzip}/bin:${pkgs.gnutar}/bin:$PATH" \
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash $INSTALL_SCRIPT
    else
      echo "Installing OpenCode CLI..."
      PATH="${pkgs.curl}/bin:${pkgs.gzip}/bin:${pkgs.gnutar}/bin:$PATH" \
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash $INSTALL_SCRIPT
    fi
    
    $DRY_RUN_CMD rm -f $INSTALL_SCRIPT
  '';
}
