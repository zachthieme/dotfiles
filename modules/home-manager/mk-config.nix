{ home-manager, minimal-tmux, nixpkgs }:
hostname:
{ system, user, isWork, packages ? [ ], ... }:
let
  contextModule =
    if isWork then
      ../../overlays/context/home-manager/work.nix
    else
      ../../overlays/context/home-manager/home.nix;
in
home-manager.lib.homeManagerConfiguration {
  inherit system;
  pkgs = nixpkgs.legacyPackages.${system};
  modules = [
    contextModule
    { home.packages = packages; }
  ];
  extraSpecialArgs = { inherit minimal-tmux; };
}
