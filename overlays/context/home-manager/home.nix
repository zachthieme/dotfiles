# Home-specific Home Manager configuration
{ pkgs, lib, config, ... }:

{
  imports = [
    ../../../home-manager/base.nix
  ];

  home.file = {
    # Add home-specific symlinks here
  };

  # Install Claude Code CLI on home machines only
  home.activation.installClaudeCode = config.lib.dag.entryAfter ["writeBoundary"] ''
    if ! command -v claude &>/dev/null; then
      echo "Installing Claude Code CLI..."
      $DRY_RUN_CMD curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code/main/install.sh | bash
    fi
  '';

}
