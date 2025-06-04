# Home-specific configuration
{ pkgs, lib, ... }:

{
  # Mark as home context (not work)
  local.isWork = false;

  # Home-specific packages
  environment.systemPackages = with pkgs; [
  ];

  # Home-specific homebrew configuration
  homebrew.casks = [
    "brave-browser"  # Use Brave at home instead of Chrome
  ];

  # Home-specific macOS settings
  system.defaults = {
    # Any home-specific macOS settings
  };
}
