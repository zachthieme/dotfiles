# M-series specific configuration
{ pkgs, lib, ... }:

{
  # Set platform for ARM (M-series) Mac
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  # M-series specific packages
  environment.systemPackages = with pkgs; [
    # ARM-specific packages would go here
  ];

  # For ARM-specific homebrew casks, use:
  # homebrew.casks = [ ... ];
}