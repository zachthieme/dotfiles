{ nix-darwin, home-manager, catppuccin, nixvim, helpers, customOverlays }:
hostname:
{ system, user, isWork, vcs, packageProfile ? "full", packages ? [ ], ... }:
let
  systemModule = ../../system/darwin.nix;
  osModule = ../../overlays/os/darwin.nix;
  contextSystemModule = helpers.selectContextModule
    isWork
    ../../overlays/context/system/home.nix
    ../../overlays/context/system/work.nix;
  contextHomeModule = helpers.selectContextModule
    isWork
    ../../overlays/context/home-manager/home.nix
    ../../overlays/context/home-manager/work.nix;
in
nix-darwin.lib.darwinSystem {
  modules = [
    { nixpkgs.hostPlatform = system;
      nixpkgs.overlays = customOverlays;
      nixpkgs.config.allowUnfreePredicate = helpers.allowUnfreePredicate; }
    systemModule
    osModule
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
