# Base configuration shared across all machines
{
  pkgs,
  lib,
  config,
  ...
}:

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
    environment.systemPackages = with pkgs; [
      bat
      btop
      browsh
      curl
      emacs
      eza
      fd
      fzf
      gh
      git
      go
      gotools
      jq
      jujutsu
      mosh
      neovim
      nixfmt-rfc-style
      nodejs_24
      pandoc
      python3
      ripgrep
      rustup
      tmux
      tree
      typst
      vim
      wget
      yazi
      zoxide
      zsh
    ];

    # Common homebrew configuration
    homebrew = {
      enable = true;
      taps = [
        "FelixKratz/formulae"
      ];
      brews = [
        "FelixKratz/formulae/borders"
        "spotify_player"
      ];
      casks = [
        "balenaetcher"
        "bartender"
        "dropbox"
        "ghostty"
        "homerow"
        "logi-options+"
        "nikitabobko/tap/aerospace"
        "spotify"
        "zed"
      ];
    };

    # Common macOS system defaults
    system.defaults = {
      dock.autohide = true;
      dock.expose-group-apps = true;
      dock.mru-spaces = false;
      finder.AppleShowAllExtensions = true;
      finder.FXPreferredViewStyle = "clmv";
      finder.ShowPathbar = true;
      NSGlobalDomain.NSWindowShouldDragOnGesture = true;
      screencapture.location = "~/Pictures/screenshots";
      screensaver.askForPasswordDelay = 10;
      spaces.spans-displays = true;
    };

    # Common keyboard settings
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    # Enable Touch ID for sudo
    security.pam.services.sudo_local.touchIdAuth = true;

    # Enable zsh
    programs.zsh.enable = true;

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

    # Allow unfree packages
    nixpkgs.config.allowUnfree = false;

    # make sure that todesk cannot be installed
    nixpkgs.overlays = [
      (self: super: {
        todesk = throw "Blocked package: todesk";
      })
    ];
  };
}
