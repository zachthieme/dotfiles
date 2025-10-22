# Home-specific Home Manager configuration
{ pkgs, lib, ... }:

let
  username = "zach";
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  imports = [
    (import ../../../home-manager/base.nix {
      inherit pkgs username homeDirectory;
    })
  ];

  home.file = {
    # Add home-specific symlinks here
  };

  home.packages = with pkgs; [
    # Home-specific packages
  ];
}
