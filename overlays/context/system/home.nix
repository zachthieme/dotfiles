# Home-specific system configuration
# This module is loaded for non-work machines (isWork = false in definitions.nix)
{ pkgs, lib, ... }:

{
  # Home-specific packages
  environment.systemPackages = with pkgs; [
  ];

  homebrew.brews = [
  ];

  homebrew.casks = [
    "brave-browser"
    "codex"
  ];

  system.defaults = {
    # Any home-specific macOS settings
  };
}
