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
      codexPkg = lib.attrByPath [ "nodePackages_latest" "codex" ] pkgs null;
      claudePkg = lib.attrByPath [ "nodePackages_latest" "claude" ] pkgs null;
      optionalPkgs = [ codexPkg claudePkg ];
    in
    lib.filter lib.isDerivation optionalPkgs
  );
}
