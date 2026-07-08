{ home-manager, nixpkgs, catppuccin, nixvim, helpers, customOverlays }:
hostname:
{ system, user, isWork, vcs, packageProfile ? "full", packages ? [ ], ... }:
let
  contextModule = helpers.selectContextModule
    isWork
    ../../overlays/context/home-manager/home.nix
    ../../overlays/context/home-manager/work.nix;
in
home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    inherit system;
    overlays = customOverlays;
    config.allowUnfreePredicate = helpers.allowUnfreePredicate;
  };
  modules = [
    catppuccin.homeModules.catppuccin
    nixvim.homeModules.nixvim
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
