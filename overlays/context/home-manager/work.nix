# Work-specific Home Manager configuration
{ pkgs, ... }:

{
  imports = [
    ../../../home-manager/base.nix
  ];

  # Work-specific shell abbreviations
  programs.fish.shellAbbrs = {
    # Override abbreviations for work machines here
  };

  home.file = {
    # Work-specific dotfiles
  };

  home.packages = with pkgs; [
    # Work-specific packages
  ];
}
