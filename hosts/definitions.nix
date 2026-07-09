{
  lib,
  helpers,
}: let
  # Required fields for each host definition
  requiredFields = ["system"];

  # Defaults applied to every host (any field can be overridden per-host)
  hostDefaults = {
    user = "zach";
    isWork = false;
    packages = [];
    # When false, install.sh refuses -f/--flake-update on this host:
    # lock bumps must land on a dev machine first, get committed, and
    # arrive here via a plain rebuild of the committed flake.lock.
    allowFlakeUpdate = true;
  };

  # Default VCS identity for git/jj (can be overridden per-host)
  defaultVcs = {
    name = "Zach Thieme";
    email = "zach@techsage.org";
  };

  # Valid package profiles
  validProfiles = ["core" "core+dev" "full"];

  # Valid system identifiers. A typo here would otherwise pass validation and
  # then match neither darwinHosts nor linuxHosts — the host silently vanishes
  # from the flake outputs while install.sh still reports it as existing.
  validSystems = ["aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux"];

  # Validate and apply defaults to a host definition
  validateHost = name: host: let
    missingFields = builtins.filter (f: !(host ? ${f})) requiredFields;
    hasMissing = builtins.length missingFields > 0;
    profile = host.packageProfile or "full";
    validProfile = builtins.elem profile validProfiles;
    validSystem = builtins.elem (host.system or null) validSystems;
  in
    if hasMissing
    then throw "Host '${name}' is missing required fields: ${builtins.concatStringsSep ", " missingFields}"
    else if !validSystem
    then throw "Host '${name}' has invalid system '${toString host.system}'. Valid values: ${builtins.concatStringsSep ", " validSystems}"
    else if !validProfile
    then throw "Host '${name}' has invalid packageProfile '${profile}'. Valid values: ${builtins.concatStringsSep ", " validProfiles}"
    else
      hostDefaults
      // host
      // {
        # Apply default VCS identity if not specified
        vcs = host.vcs or defaultVcs;
        # Apply default package profile if not specified
        packageProfile = profile;
      };

  # Raw host definitions (validated below; hostDefaults fills user/isWork/packages)
  rawHosts = {
    "cortex" = {
      system = "aarch64-darwin";
    };
    "malv2" = {
      system = "x86_64-darwin";
    };
    "zthieme34911" = {
      system = "aarch64-darwin";
      user = "zthieme";
      isWork = true;
    };
    "prod" = {
      system = "x86_64-linux";
      allowFlakeUpdate = false;
    };
    "dev" = {
      system = "x86_64-linux";
    };
    "util" = {
      system = "x86_64-linux";
    };
    "claude" = {
      system = "x86_64-linux";
    };
    "omarchy" = {
      system = "x86_64-linux";
    };
    "pi5" = {
      system = "aarch64-linux";
      packageProfile = "core";
    };
    "pi-nomad1" = {
      system = "aarch64-linux";
      packageProfile = "core";
      allowFlakeUpdate = false;
    };
    "pi-nomad2" = {
      system = "aarch64-linux";
      packageProfile = "core";
      allowFlakeUpdate = false;
    };
    "pi-nomad3" = {
      system = "aarch64-linux";
      packageProfile = "core";
      allowFlakeUpdate = false;
    };
  };

  # Apply validation to all hosts
  hosts = lib.mapAttrs validateHost rawHosts;

  # Use shared helper functions to avoid duplication
  isDarwin = host: helpers.isDarwin host.system;
  isLinux = host: helpers.isLinux host.system;
in {
  inherit hosts;
  darwinHosts = lib.filterAttrs (_: host: isDarwin host) hosts;
  linuxHosts = lib.filterAttrs (_: host: isLinux host) hosts;
}
