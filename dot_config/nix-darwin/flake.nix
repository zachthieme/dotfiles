{
  description = "nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          system.primaryUser = "zach";
          # List packages installed in system profile. To search by name, run:
          environment.systemPackages = [
            pkgs.bat
            pkgs.curl
            pkgs.dotnetCorePackages.dotnet_9.runtime
            pkgs.dotnetCorePackages.dotnet_9.sdk
            pkgs.emacs
            pkgs.eza
            pkgs.fd
            pkgs.fzf
            pkgs.gh
            pkgs.git
            pkgs.go
            pkgs.gotools
            pkgs.jq
            pkgs.mosh
            pkgs.neovim
            pkgs.nixfmt-rfc-style
            pkgs.nodejs_24
            pkgs.pandoc
            pkgs.pass
            pkgs.python3
            pkgs.ripgrep
            pkgs.tmux
            pkgs.vim
            pkgs.wget
            pkgs.yazi
            pkgs.zoxide
            pkgs.zsh
          ];

          homebrew = {
            enable = true;
            # onActivation.cleanup = "uninstall";

            taps = [
              "FelixKratz/formulae"
            ];
            brews = [
              "FelixKratz/formulae/borders"
              "FelixKratz/formulae/sketchybar"
              "oh-my-posh"
              "spotify_player"
            ];
            casks = [
              "balenaetcher"
              "bartender"
              "brave-browser"
              "dropbox"
              "ghostty"
              "homerow"
              "nikitabobko/tap/aerospace"
              "raycast"
              "spotify"
              "wezterm"
              "zed"
            ];
          };

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";
          nix.enable = false;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # configuring mac os
          # use touchid in terminal
          security.pam.services.sudo_local.touchIdAuth = true;

          system.defaults = {
            dock.autohide = true;
            finder.AppleShowAllExtensions = true;
            finder.FXPreferredViewStyle = "clmv";
            screencapture.location = "~/Pictures/screenshots";
            screensaver.askForPasswordDelay = 10;

            # aerospace configuration
            dock.mru-spaces = false;
            dock.expose-group-apps = true;
            spaces.spans-displays = true;
            NSGlobalDomain.NSWindowShouldDragOnGesture = true;
          };
          system.keyboard = {
            enableKeyMapping = true;
            remapCapsLockToEscape = true;
          };

          # Used for backwards compatibility, please read the changelog before changing.
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."Cortex" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
