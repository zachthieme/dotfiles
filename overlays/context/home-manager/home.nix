# Home-specific Home Manager configuration
{ pkgs, lib, ... }:

{
  imports = [
    ../../../home-manager/base.nix
  ];

  home.file = {
    # Add home-specific symlinks here
  };

  home.packages = lib.mkAfter (
    let
      claudePkg = lib.attrByPath [ "nodePackages_latest" "claude" ] pkgs null;
    in
    [ pkgs.nodePackages_latest.codex ]
    ++ lib.optionals (claudePkg != null) [ claudePkg ]
  );
}
