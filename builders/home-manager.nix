{
  home-manager,
  nixpkgs,
  catppuccin,
  helpers,
  customOverlays,
}: hostname: host @ {
  # All fields are guaranteed by validateHost in hosts/definitions.nix —
  # defaults live there, not here
  system,
  isWork,
  ...
}: let
  contextModule =
    helpers.selectContextModule
    isWork
    ../contexts/home-manager/home.nix
    ../contexts/home-manager/work.nix;
in
  home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs {
      inherit system;
      overlays = customOverlays;
      config.allowUnfreePredicate = helpers.allowUnfreePredicate;
    };
    modules = [
      catppuccin.homeModules.catppuccin
      contextModule
      # Per-host user wiring (username, homeDirectory, packages, vcs,
      # packageProfile) — shared with builders/darwin.nix
      (helpers.mkUserModule host)
    ];
  }
