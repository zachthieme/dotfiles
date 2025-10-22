# Home-specific Home Manager configuration
{ pkgs, lib, ... }:

{
  imports = [
    ../../../home-manager/base.nix
  ];

  home.file = {
    # Add home-specific symlinks here
  };

  home.packages = lib.mkAfter (with pkgs; [
    nodePackages_latest.claude
    nodePackages_latest.codex
  ]);
}
