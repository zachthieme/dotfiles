# Home-specific Home Manager configuration
{ pkgs, lib, ... }:

{
  imports = [
    ../../../home-manager/base.nix
  ];

  home.file = {
    # Add home-specific symlinks here
  };

  home.packages = with pkgs; [
    # Home-specific packages
  ];
}
