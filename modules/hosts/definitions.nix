{ lib }:
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
  };

  isDarwin = host: builtins.match ".*-darwin" host.system != null;
  isLinux = host: builtins.match ".*-linux" host.system != null;
in
{
  inherit hosts;
  darwinHosts = lib.filterAttrs (_: host: isDarwin host) hosts;
  linuxHosts = lib.filterAttrs (_: host: isLinux host) hosts;
}
