# Base configuration shared across all machines
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

    
    # Set primary user based on configuration
    system.primaryUser = config.local.username;

    # Define user based on configuration
    users.users.${config.local.username} = {
      home = "/Users/${config.local.username}";
      shell = pkgs.zsh;
    };

    # Set networking hostname
    networking.hostName = config.local.hostname;

    # System activation script
    system.activationScripts.postActivation.text = ''
      echo "${
        if config.local.isWork then "Work" else "Home"
      } MacBook configuration for ${config.local.hostname} activated"
    '';

    # Common system settings
    system.stateVersion = 6;
    nix.enable = false;

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
