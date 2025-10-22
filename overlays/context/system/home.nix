# Home-specific system configuration
{ pkgs, lib, ... }:

{
  # Mark as home context (not work)
  local.isWork = false;

  # Home-specific packages
  environment.systemPackages = with pkgs; [
  ];

  homebrew.brews = [
    "codex"
  ];

  homebrew.casks = [
    "brave-browser"
  ];

  system.defaults = {
    # Any home-specific macOS settings
  };
}
