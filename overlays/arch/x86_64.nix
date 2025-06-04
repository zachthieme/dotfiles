# Intel architecture specific configuration
{ pkgs, lib, ... }:

{
  # Set platform for Intel Mac
  nixpkgs.hostPlatform = "x86_64-darwin";
  
  # Intel specific packages
  environment.systemPackages = with pkgs; [
    # Intel-specific packages would go here
  ];

  # For Intel-specific homebrew casks, use:
  # homebrew.casks = [ ... ];
}