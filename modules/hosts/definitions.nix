{ lib, helpers }:
let
  # Required fields for each host definition
  requiredFields = [ "system" "user" "isWork" ];


  # Default VCS identity for git/jj (can be overridden per-host)
  defaultVcs = {
    name = "Zach Thieme";
    email = "zach@techsage.org";
  };

  # Validate and apply defaults to a host definition
  validateHost = name: host:
    let
      missingFields = builtins.filter (f: !(host ? ${f})) requiredFields;
      hasMissing = builtins.length missingFields > 0;
      profile = host.packageProfile or "full";
      validProfile = builtins.elem profile validProfiles;
    in
    if hasMissing then
      throw "Host '${name}' is missing required fields: ${builtins.concatStringsSep ", " missingFields}"
    else if !validProfile then
      throw "Host '${name}' has invalid packageProfile '${profile}'. Valid values: ${builtins.concatStringsSep ", " validProfiles}"
    else
      host // {
        # Apply default VCS identity if not specified
        vcs = host.vcs or defaultVcs;
        # Apply default package profile if not specified
        packageProfile = profile;
      };

  # Valid package profiles
  validProfiles = [ "core" "core+dev" "full" ];

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
    "prod" = {
      system = "x86_64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "dev" = {
      system = "x86_64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "util" = {
      system = "x86_64-linux";
      user = "zach";
      isWork = false;
      packages = [ ];
    };
    "claude" = {
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
    "pi5" = {
      system = "aarch64-linux";
      user = "zach";
      isWork = false;
      packageProfile = "core";
      packages = [ ];
    };
    "pi-nomad1" = {
      system = "aarch64-linux";
      user = "zach";
      isWork = false;
      packageProfile = "core";
      packages = [ ];
    };
    "pi-nomad2" = {
      system = "aarch64-linux";
      user = "zach";
      isWork = false;
      packageProfile = "core";
      packages = [ ];
    };
    "pi-nomad3" = {
      system = "aarch64-linux";
      user = "zach";
      isWork = false;
      packageProfile = "core";
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
