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
  pkgs = import nixpkgs {
    inherit system;
    # Allow specific unfree packages (vault has BSL license)
    # On Darwin, this is handled at the system level in system/darwin.nix
    config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "vault" ];
  };
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
