{ lib, helpers }:
let
  hosts = {
    "cortex" = {
      system = "aarch64-darwin";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "malv2" = {
      system = "x86_64-darwin";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "zthieme34911" = {
      system = "aarch64-darwin";
      user = "zthieme";
      isWork = true;
      packages = [ ];
    };
    "srv722852" = {
      system = "x86_64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "omarchy" = {
      system = "x86_64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "srv1089402" = {
      system = "x86_64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "pi5" = {
      system = "aarch64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "pi-nomad1" = {
      system = "aarch64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "pi-nomad2" = {
      system = "aarch64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "pi-nomad3" = {
      system = "aarch64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
  };

  # Use shared helper functions to avoid duplication
  isDarwin = host: helpers.isDarwin host.system;
  isLinux = host: helpers.isLinux host.system;
in
{
  inherit hosts;
  darwinHosts = lib.filterAttrs (_: host: isDarwin host) hosts;
  linuxHosts = lib.filterAttrs (_: host: isLinux host) hosts;
}
