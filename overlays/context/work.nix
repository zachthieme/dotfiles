# Work-specific configuration
{ pkgs, lib, ... }:

{
  # Mark as work context
  local.isWork = true;

  # Set work username
  local.username = "zthieme";

  # Work-specific packages
  environment.systemPackages = with pkgs; [
  ];

  # Work-specific homebrew configuration
  homebrew.casks = [
    "google-chrome"  # Use Chrome at work instead of Brave
  ];

  # Work-specific macOS settings
  system.defaults = {
    # Any work-specific macOS settings
  };
}
