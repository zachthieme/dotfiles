{ nix-darwin, home-manager, helpers }:
hostname:
{ system, user, isWork, packages ? [ ], ... }:
let
  baseModule = ../../base/default.nix;
  osModule = ../../overlays/os/darwin.nix;
  archModule =
    if system == "aarch64-darwin" then
      ../../overlays/arch/aarch64.nix
    else
      ../../overlays/arch/x86_64.nix;
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
    archModule
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
      home-manager.users.${user} = {
        imports = [ contextHomeModule ];
        home.username = user;
        home.homeDirectory = helpers.getHomeDirectory user system;
      };
    }
  ];
}
