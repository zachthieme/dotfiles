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
    # Home-specific packages
  ];

  # Install Claude Code CLI on home machines only
  # Note: Uses official installer since claude-code isn't in nixpkgs yet
  # Download script first, then run with required tools in PATH
  home.activation.installClaudeCode = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "${config.home.homeDirectory}/.local/bin/claude" ]; then
      echo "Installing Claude Code CLI..."
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh -o /tmp/claude-install.sh
      PATH="${pkgs.curl}/bin:${pkgs.gzip}/bin:${pkgs.gnutar}/bin:$PATH" \
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash /tmp/claude-install.sh
      rm -f /tmp/claude-install.sh
    fi
  '';
}
