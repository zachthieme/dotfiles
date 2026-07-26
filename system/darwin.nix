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
    #
    # The Homebrew cleanup step runs here rather than via
    # `homebrew.onActivation.cleanup = "uninstall"`: nix-darwin still builds that
    # into `brew bundle --force-cleanup`, a flag Homebrew dropped in 5.x (cleanup
    # is now the `brew bundle cleanup --force` subcommand). Passing it makes brew
    # exit with "invalid option: --force-cleanup" and aborts the rebuild. This
    # reimplements nix-darwin's invocation with the current CLI; drop it once
    # nix-darwin emits the subcommand form. postActivation runs immediately after
    # nix-darwin's own homebrew script, so packages are installed before cleanup.
    system.activationScripts.postActivation.text = ''
      if [ -f "${config.homebrew.prefix}/bin/brew" ]; then
        echo >&2 "Homebrew cleanup..."
        PATH="${config.homebrew.prefix}/bin:${lib.makeBinPath [pkgs.mas]}:$PATH" \
          sudo --preserve-env=PATH --user=${lib.escapeShellArg config.homebrew.user} --set-home \
          env HOMEBREW_NO_AUTO_UPDATE=1 \
          brew bundle cleanup --force --file='${pkgs.writeText "Brewfile" config.homebrew.brewfile}'
      fi

      echo "${
        if config.local.isWork
        then "Work"
        else "Home"
      } system configuration for ${config.local.hostname} activated"
    '';

    # Common system settings
    system.stateVersion = 6;
    # Determinate Nix owns Nix itself (flakes + nix-command are enabled out of
    # the box), so nix-darwin must not manage it. With nix.enable = false,
    # nix-darwin writes no nix.conf — nix.package / nix.settings.* would be dead,
    # so they are intentionally not set here.
    nix.enable = false;

    # Homebrew packages and casks shared by all macOS machines
    # (context-specific casks live in contexts/system/{home,work}.nix)
    homebrew = {
      enable = true;
      # Anything not declared here or in contexts/system/ is uninstalled —
      # without that the Homebrew layer is append-only (removing a cask from
      # config leaves it installed forever). NOTE: this also removes manually
      # `brew install`ed packages on the next rebuild; declare them instead.
      # The cleanup itself runs from postActivation above, not from
      # `onActivation.cleanup` — see the comment there for why.
      onActivation.cleanup = "none";
      taps = [
        "FelixKratz/formulae"
        # Home of the aerospace cask below — declare it or cleanup untaps it
        # while the cask that came from it is still installed.
        "nikitabobko/tap"
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
