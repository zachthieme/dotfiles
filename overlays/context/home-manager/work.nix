# Work-specific Home Manager configuration
{ pkgs, lib, ... }:

let
  username = "zthieme";
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  imports = [
    (import ../../../home-manager/base.nix {
      inherit pkgs username homeDirectory;
    })
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
