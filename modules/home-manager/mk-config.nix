{ home-manager, nixpkgs, catppuccin, helpers }:
hostname:
{ system, user, isWork, vcs, packageProfile ? "full", packages ? [ ], ... }:
let
  contextModule = helpers.selectContextModule
    isWork
    ../../overlays/context/home-manager/home.nix
    ../../overlays/context/home-manager/work.nix;
in
home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.${system};
  modules = [
    catppuccin.homeModules.catppuccin
    contextModule
    {
      home.username = user;
      home.homeDirectory = helpers.getHomeDirectory user system;
      home.packages = packages;
      dotfiles.vcs = vcs;
      dotfiles.packageProfile = packageProfile;
    }
  ];
}
