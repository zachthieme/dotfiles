{ nix-darwin, home-manager, catppuccin, helpers }:
hostname:
{ system, user, isWork, packages ? [ ], ... }:
let
  baseModule = ../../base/darwin.nix;
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
  inherit system;
  modules = [
    baseModule
    osModule
    contextSystemModule
    {
      local.hostname = hostname;
      local.username = user;
      environment.systemPackages = packages;
    }
    home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.${user} = {
        imports = [
          catppuccin.homeModules.catppuccin
          contextHomeModule
        ];
        home.username = user;
        home.homeDirectory = helpers.getHomeDirectory user system;
      };
    }
  ];
}
