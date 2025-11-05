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
    if [ ! -f "${config.home.homeDirectory}/.local/bin/claude" ]; then
      echo "Installing Claude Code CLI..."
      export PATH="${pkgs.curl}/bin:${pkgs.wget}/bin:$PATH"
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | ${pkgs.bash}/bin/bash
    fi
  '';

}
