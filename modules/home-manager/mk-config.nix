{
  home-manager,
  nixpkgs,
  catppuccin,
  nixvim,
  helpers,
  customOverlays,
}: hostname: {
  # All fields are guaranteed by validateHost in modules/hosts/definitions.nix —
  # defaults live there, not here
  system,
  user,
  isWork,
  vcs,
  packageProfile,
  packages,
  ...
}: let
  contextModule =
    helpers.selectContextModule
    isWork
    ../../contexts/home-manager/home.nix
    ../../contexts/home-manager/work.nix;
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
