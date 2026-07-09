{
  nix-darwin,
  home-manager,
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
  systemModule = ../../system/darwin.nix;
  contextSystemModule =
    helpers.selectContextModule
    isWork
    ../../contexts/system/home.nix
    ../../contexts/system/work.nix;
  contextHomeModule =
    helpers.selectContextModule
    isWork
    ../../contexts/home-manager/home.nix
    ../../contexts/home-manager/work.nix;
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
          ];
          home.username = user;
          home.homeDirectory = helpers.getHomeDirectory user system;
          # Host-specific packages install at the user level on both platforms
          home.packages = packages;
          dotfiles.vcs = vcs;
          dotfiles.packageProfile = packageProfile;
        };
      }
    ];
  }
