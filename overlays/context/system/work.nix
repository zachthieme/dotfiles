# Work-specific system configuration
# This module is loaded for work machines (isWork = true in definitions.nix)
{ pkgs, lib, ... }:

{
  # Work-specific packages
  environment.systemPackages = with pkgs; [
  ];

  homebrew.casks = [
    "google-chrome"
  ];

  system.defaults = {
    # Any work-specific macOS settings
  };
}
