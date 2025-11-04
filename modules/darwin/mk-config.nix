{ nix-darwin, home-manager }:
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
  contextSystemModule =
    if isWork then
      ../../overlays/context/system/work.nix
    else
      ../../overlays/context/system/home.nix;
  contextHomeModule =
    if isWork then
      ../../overlays/context/home-manager/work.nix
    else
      ../../overlays/context/home-manager/home.nix;
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
        home.homeDirectory =
          if builtins.match ".*-darwin" system != null then
            "/Users/${user}"
          else
            "/home/${user}";
      };
    }
  ];
}
