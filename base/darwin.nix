# Base system configuration for nix-darwin and NixOS machines
# Note: Linux Home Manager-only configs use home-manager/base.nix instead
{
  pkgs,
  lib,
  config,
  ...
}:

let
  packageProfiles = import ../packages/common.nix { inherit pkgs; };
in
{
  # Accept arguments for user-specific settings with defaults
  options = {
    local = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "The primary user's username";
        default = "zach";
      };

      isWork = lib.mkOption {
        type = lib.types.bool;
        description = "Whether this is a work machine";
        default = false;
      };

      hostname = lib.mkOption {
        type = lib.types.str;
        description = "The hostname of the machine";
        default = "cortex";
      };
    };
  };

  config = {

    # Common system packages for all machines
    environment.systemPackages = packageProfiles.profiles.basePackages;
    programs.fish.enable = true;

    # Set primary user based on configuration
    system.primaryUser = config.local.username;

    # Define user based on configuration
    users.users.${config.local.username} = {
      home = "/Users/${config.local.username}";
      shell = pkgs.fish;
    };

    # Set networking hostname
    networking.hostName = config.local.hostname;

    # System activation script
    system.activationScripts.postActivation.text = ''
      echo "${
        if config.local.isWork then "Work" else "Home"
      } system configuration for ${config.local.hostname} activated"
    '';

    # Common system settings
    system.stateVersion = 6;
    # Disable nix-darwin's Nix management when using Determinate Nix
    nix.enable = false;
    # Required even with nix.enable = false for nix.conf generation
    nix.package = pkgs.nix;

    # Allow selective unfree packages
    nixpkgs.config = {
      allowUnfree = false;
    };

    # make sure that todesk cannot be installed
    nixpkgs.overlays = [
      (self: super: {
        todesk = throw "Blocked package: todesk";
      })
    ];
  };
}
