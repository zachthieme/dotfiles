{
  description = "nix-darwin + Home Manager setup with fish-like Zsh";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      system =
        if
          builtins.elem (builtins.getEnv "NIX_SYSTEM") [
            "aarch64-darwin"
            "x86_64-darwin"
          ]
        then
          builtins.getEnv "NIX_SYSTEM"
        else
          "aarch64-darwin"; # fallback default for M1/M2

      pkgs = import nixpkgs { inherit system; };
    in
    {
      darwinConfigurations."Cortex" = nix-darwin.lib.darwinSystem {
        inherit system;

        modules = [
          {
            nixpkgs.hostPlatform = system;

            # Enable nix-darwin system settings
            environment.systemPackages = with pkgs; [
              bat
              chezmoi
              curl
              dotnetCorePackages.dotnet_9.runtime
              dotnetCorePackages.dotnet_9.sdk
              emacs
              eza
              fd
              fzf
              gh
              git
              go
              gotools
              jq
              mosh
              neovim
              nixfmt-rfc-style
              nodejs_24
              pandoc
              pass
              python3
              ripgrep
              tmux
              tree
              vim
              wget
              yazi
              zoxide
              zsh
            ];

            system.primaryUser = "zach";

            homebrew = {
              enable = true;
              # onActivation.cleanup = "uninstall";

              taps = [
                "FelixKratz/formulae"
              ];
              brews = [
                "FelixKratz/formulae/borders"
                "FelixKratz/formulae/sketchybar"
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
            nix.enable = false;
            system.stateVersion = 6;
            system.configurationRevision = self.rev or self.dirtyRev or null;

            programs.zsh.enable = true;

            users.users.zach = {
              home = "/Users/zach";
              shell = pkgs.zsh;
            };
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
          }

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.zach = import ./home.nix;
          }
        ];
      };
    };
}
