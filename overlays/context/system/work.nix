# Work-specific system configuration
{ pkgs, lib, ... }:

{
  # Mark as work context
  local.isWork = true;

  # Set work username
  local.username = "zthieme";

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
