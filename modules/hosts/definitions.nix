{ lib, helpers }:
let
  # Required fields for each host definition
  requiredFields = [ "system" "user" "isWork" ];

  # Default git identity (can be overridden per-host)
  defaultGit = {
    name = "Zach Thieme";
    email = "zach@techsage.org";
  };

  # Validate and apply defaults to a host definition
  validateHost = name: host:
    let
      missingFields = builtins.filter (f: !(host ? ${f})) requiredFields;
      hasMissing = builtins.length missingFields > 0;
    in
    if hasMissing then
      throw "Host '${name}' is missing required fields: ${builtins.concatStringsSep ", " missingFields}"
    else
      host // {
        # Apply default git identity if not specified
        git = host.git or defaultGit;
      };

  # Raw host definitions (validated below)
  rawHosts = {
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

  # Apply validation to all hosts
  hosts = lib.mapAttrs validateHost rawHosts;

  # Use shared helper functions to avoid duplication
  isDarwin = host: helpers.isDarwin host.system;
  isLinux = host: helpers.isLinux host.system;
in
{
  inherit hosts;
  darwinHosts = lib.filterAttrs (_: host: isDarwin host) hosts;
  linuxHosts = lib.filterAttrs (_: host: isLinux host) hosts;
}
