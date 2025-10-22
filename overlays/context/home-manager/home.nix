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
      codexPkg = pkgs.callPackage ../../../packages/node/codex.nix { };
      claudePkg = pkgs.callPackage ../../../packages/node/claude.nix { };
      optionalPkgs = [ codexPkg claudePkg ];
    in
    lib.filter lib.isDerivation optionalPkgs
  );
}
