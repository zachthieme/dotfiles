# Work-specific Home Manager configuration
#
# Intentionally minimal: work machines use the same base config as home machines.
# Add work-specific overrides here only when they diverge from the shared base
# (e.g., different shell abbreviations, work-only packages, or work-specific dotfiles).
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
