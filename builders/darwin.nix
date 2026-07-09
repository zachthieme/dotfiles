{
  nix-darwin,
  home-manager,
  catppuccin,
  nixvim,
  helpers,
  customOverlays,
}: hostname: host @ {
  # All fields are guaranteed by validateHost in hosts/definitions.nix —
  # defaults live there, not here
  system,
  user,
  isWork,
  ...
}: let
  systemModule = ../system/darwin.nix;
  contextSystemModule =
    helpers.selectContextModule
    isWork
    ../contexts/system/home.nix
    ../contexts/system/work.nix;
  contextHomeModule =
    helpers.selectContextModule
    isWork
    ../contexts/home-manager/home.nix
    ../contexts/home-manager/work.nix;
in
  nix-darwin.lib.darwinSystem {
    modules = [
      {
        nixpkgs.hostPlatform = system;
        nixpkgs.overlays = customOverlays;
        nixpkgs.config.allowUnfreePredicate = helpers.allowUnfreePredicate;
      }
      systemModule
      contextSystemModule
      {
        local.hostname = hostname;
        local.username = user;
        local.isWork = isWork;
      }
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.users.${user} = {
          imports = [
            catppuccin.homeModules.catppuccin
            nixvim.homeModules.nixvim
            contextHomeModule
            # Per-host user wiring (username, homeDirectory, packages, vcs,
            # packageProfile) — shared with builders/home-manager.nix
            (helpers.mkUserModule host)
          ];
        };
      }
    ];
  }
