{ home-manager, nixpkgs }:
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
  pkgs = nixpkgs.legacyPackages.${system};
  modules = [
    contextModule
    {
      home.username = user;
      home.homeDirectory =
        if builtins.match ".*-darwin" system != null then
          "/Users/${user}"
        else
          "/home/${user}";
      home.packages = packages;
    }
  ];
}
