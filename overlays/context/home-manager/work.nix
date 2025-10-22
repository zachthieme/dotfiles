# Work-specific Home Manager configuration
{ pkgs, lib, ... }:

{
  imports = [
    ../../../home-manager/base.nix
  ];

  programs.zsh.shellAliases = {
    # Override aliases for work machines here
  };

  home.file = {
    # Work-specific adjustments
  };

  home.packages = with pkgs; [
    # Work-specific packages
  ];
}
