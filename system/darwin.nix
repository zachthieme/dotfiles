# System configuration shared by all nix-darwin machines
# (packages, users, hostname, Homebrew, macOS defaults)
# Note: Linux Home Manager-only configs use home-manager/base.nix instead
{
  pkgs,
  lib,
  config,
  ...
}: {
  # Accept arguments for user-specific settings with defaults
  options = {
    local = {
      # No defaults: the builder (builders/darwin.nix) always sets these
      # from definitions.nix, and a missing value should fail loudly at eval time
      username = lib.mkOption {
        type = lib.types.str;
        description = "The primary user's username";
      };

      isWork = lib.mkOption {
        type = lib.types.bool;
        description = "Whether this is a work machine";
      };

      hostname = lib.mkOption {
        type = lib.types.str;
        description = "The hostname of the machine";
      };
    };
  };

  config = {
    # System-level packages (most packages go in home-manager/base.nix to avoid duplication)
    # Only include packages that must be system-level (e.g., login shell)
    environment.systemPackages = with pkgs; [
      helix
      vault
    ];
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
        if config.local.isWork
        then "Work"
        else "Home"
      } system configuration for ${config.local.hostname} activated"
    '';

    # Common system settings
    system.stateVersion = 6;
    # Disable nix-darwin's Nix management when using Determinate Nix
    nix.enable = false;
    # Required even with nix.enable = false for nix.conf generation
    nix.package = pkgs.nix;
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Homebrew packages and casks shared by all macOS machines
    # (context-specific casks live in contexts/system/{home,work}.nix)
    homebrew = {
      enable = true;
      taps = [
        "FelixKratz/formulae"
      ];
      brews = [
        "FelixKratz/formulae/borders"
        "spotify_player"
        "bazelisk"
      ];
      casks = [
        "balenaetcher"
        "bartender"
        "dropbox"
        "ghostty"
        "homerow"
        "keycastr"
        "logi-options+"
        "nikitabobko/tap/aerospace"
        "spotify"
        "zed"
      ];
    };

    # macOS defaults
    system.defaults = {
      dock.autohide = true;
      dock.expose-group-apps = true;
      dock.expose-animation-duration = 0.1;
      dock.mru-spaces = false;
      finder.AppleShowAllExtensions = true;
      finder.FXPreferredViewStyle = "clmv";
      finder.ShowPathbar = true;
      NSGlobalDomain.NSWindowShouldDragOnGesture = true;
      screencapture.location = "~/Pictures/screenshots";
      screensaver.askForPasswordDelay = 10;
      spaces.spans-displays = true;
    };

    # Keyboard settings
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    # Enable Touch ID for sudo
    security.pam.services.sudo_local.touchIdAuth = true;

    # Unfree packages are allowed via helpers.allowUnfreePredicate,
    # set by the builder in builders/darwin.nix

    # Block todesk — unapproved remote-access software (security policy)
    nixpkgs.overlays = [
      (_self: _super: {
        todesk = throw "Blocked package: todesk";
      })
    ];
  };
}
