{
  description = "nix-darwin multi-machine configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nix-darwin, nixpkgs }:
    let
      # Determine hostname and architecture at evaluation time
      inherit (builtins) currentSystem;
      hostName = builtins.getEnv "HOSTNAME";

      # Mapping hostnames to platforms
      hostPlatform = {
        Cortex = "aarch64-darwin";       # M4
        mal = "x86_64-darwin";           # Intel
        zthieme34111 = "aarch64-darwin"; # M1
      };

      # Configuration function
      commonConfiguration = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
          bat 
          curl 
          dotnetCorePackages.dotnet_9.runtime 
          dotnetCorePackages.dotnet_9.sdk
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
          nodejs_23
          pandoc 
          pass 
          python3 
          ripgrep 
          tmux 
          vim 
          wget 
          yazi 
          zoxide 
          zsh
        ];

        homebrew = {
          enable = true;
          taps = [ "FelixKratz/formulae" ];
          brews = [
            "FelixKratz/formulae/borders"
            "FelixKratz/formulae/sketchybar"
            "oh-my-posh" 
            "sesh" 
            "spotify_player"
          ];
          casks = [
            "brave-browser" 
            "dropbox" 
            "ghostty"
            "nikitabobko/tap/aerospace" 
            "raycast"
            "spotify" 
            "zed"
          ];
        };

        nix.settings.experimental-features = "nix-command flakes";
        nix.enable = false;
        system.configurationRevision = self.rev or self.dirtyRev or null;

        security.pam.services.sudo_local.touchIdAuth = true;

        system.defaults = {
          dock.autohide = true;
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "clmv";
          screencapture.location = "~/Pictures/screenshots";
          screensaver.askForPasswordDelay = 10;
          dock.mru-spaces = false;
          dock.expose-group-apps = true;
          spaces.spans-displays = true;
          NSGlobalDomain.NSWindowShouldDragOnGesture = true;
        };

        system.keyboard = {
          enableKeyMapping = true;
          remapCapsLockToEscape = true;
        };

        programs.zsh.enable = true;
        system.stateVersion = 6;
      };
    in {
      darwinConfigurations = {
        Cortex = nix-darwin.lib.darwinSystem {
          system = hostPlatform.Cortex;
          modules = [ commonConfiguration ];
        };
        mal = nix-darwin.lib.darwinSystem {
          system = hostPlatform.mal;
          modules = [ commonConfiguration ];
        };
        zthieme34111 = nix-darwin.lib.darwinSystem {
          system = hostPlatform.zthieme34111;
          modules = [ commonConfiguration ];
        };
      };
    };
}
