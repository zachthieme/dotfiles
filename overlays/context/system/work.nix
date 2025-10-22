# Work-specific system configuration
{ pkgs, lib, ... }:

{
  # Mark as work context
  local.isWork = true;

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
