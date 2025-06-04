# Home-specific configuration
{ pkgs, lib, ... }:

{
  # Mark as home context (not work)
  local.isWork = false;
  
  # Home-specific packages
  environment.systemPackages = with pkgs; [
    dotnetCorePackages.dotnet_9.runtime
    dotnetCorePackages.dotnet_9.sdk
    emacs
    pass
  ];

  # Home-specific homebrew configuration
  homebrew.casks = [
    "brave-browser"  # Use Brave at home instead of Chrome
    "emacs"
  ];

  # Home-specific macOS settings
  system.defaults = {
    # Any home-specific macOS settings
  };
}