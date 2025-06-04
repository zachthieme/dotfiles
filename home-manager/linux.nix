# Linux-specific Home Manager configuration
{ pkgs, lib, ... }:

let
  username = "zach";
  homeDirectory = "/home/${username}";
in
{
  # Import the base configuration with our username and home directory
  imports = [
    (import ./base.nix {
      inherit pkgs username homeDirectory;
    })
  ];

  # Linux-specific file symlinks
  home.file = {
    # Add Linux-specific symlinks here
  };

  # Linux-specific packages
  home.packages = with pkgs; [
  ];

  # Linux-specific program configurations
  services = {
  };
}
