{
  description = "Nix configuration for multiple machines (MacBooks and Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # For macOS configurations
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For NixOS Linux configurations
    nixos = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional flake inputs
    minimal-tmux = {
      url = "github:niksingh710/minimal-tmux-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nixos, nix-darwin, home-manager, minimal-tmux, ... }:
    let
      # Host definitions
      hosts = {
        "cortex" = {
          system = "aarch64-darwin";
          user = "zach";
          isWork = false;
          packages = []; # Add any host-specific packages here
        };
        "malv2" = {
          system = "x86_64-darwin";
          user = "zach";
          isWork = false;
          packages = []; # Add any host-specific packages here
        };
        "zthieme34911" = {
          system = "aarch64-darwin";
          user = "zthieme";
          isWork = true;
          packages = []; # Add any host-specific packages here
        };
        "jayne" = {
          system = "x86_64-linux";
          user = "zach";
          isWork = false;
          packages = with pkgs; [
            # AMD-specific packages
            # amdgpu_top
            # Any other Pop!_OS specific packages
          ];
        };
      };

      # Helper function to create configurations based on system type
      mkConfig = hostname: { system, user, isWork, packages ? [], ... }:
        let
          # Determine if this is a Darwin (macOS) or Linux system
          isDarwin = builtins.match ".*-darwin" system != null;

          # Context-specific home-manager files
          homeManagerModule =
            if isDarwin then
              if isWork then ./home-manager/work.nix else ./home-manager/home.nix
            else
              ./home-manager/linux.nix;

          # Architecture-specific module
          archModule =
            if system == "aarch64-darwin" then ./overlays/arch/aarch64.nix
            else if system == "x86_64-darwin" then ./overlays/arch/x86_64.nix
            else if system == "x86_64-linux" then ./overlays/arch/x86_64-linux.nix
            else throw "Unsupported system: ${system}";

          # Context-specific module
          contextSystemModule =
            if isDarwin then
              if isWork then ./overlays/context/work.nix else ./overlays/context/home.nix
            else
              ./overlays/context/linux.nix;
        in
        if isDarwin then
          # macOS configuration using nix-darwin
          nix-darwin.lib.darwinSystem {
            inherit system;
            modules = [
              # Base system configuration
              ./base/default.nix

              # Architecture and context overlays
              archModule
              contextSystemModule

              # Host-specific configuration
              {
                # Set hostname
                local.hostname = hostname;

                # Add any host-specific packages
                environment.systemPackages = packages;
              }

              # Home Manager module
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${user} = import homeManagerModule;
              }
            ];
            specialArgs = { inherit minimal-tmux; };
          }
        else
          # Linux configuration using NixOS
          nixos.lib.nixosSystem {
            inherit system;
            modules = [
              # Base system configuration
              ./base/default.nix

              # Architecture and context overlays
              archModule
              contextSystemModule

              # Host-specific configuration
              {
                # Set hostname
                local.hostname = hostname;
                networking.hostName = hostname;

                # Add any host-specific packages
                environment.systemPackages = packages;

                # Set the user
                users.users.${user} = {
                  isNormalUser = true;
                  home = "/home/${user}";
                  extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
                  shell = pkgs.zsh;
                };
              }

              # Home Manager module
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${user} = import homeManagerModule;
              }
            ];
            specialArgs = { inherit minimal-tmux; };
          };

      # Auto-detection for default configuration
      detectHost =
        let
          hostname = builtins.getEnv "HOSTNAME";
          system = builtins.getEnv "NIX_SYSTEM";
          isAarch64 = builtins.match "aarch64-darwin" system != null;
          isLinux = builtins.match ".*-linux" system != null;
          isWork = builtins.match "zthieme.*" hostname != null;
        in
          if builtins.hasAttr hostname hosts then
            hostname
          else if isWork then
            "zthieme34911"
          else if isLinux then
            "ryzen-pop"
          else if isAarch64 then
            "cortex"
          else
            "malv2";
    in
    {
      # macOS configurations
      darwinConfigurations = builtins.mapAttrs mkConfig (lib.filterAttrs (n: v: builtins.match ".*-darwin" v.system != null) hosts) // {
        default = self.darwinConfigurations.${detectHost} or self.darwinConfigurations.cortex;
      };

      # NixOS configurations
      nixosConfigurations = builtins.mapAttrs mkConfig (lib.filterAttrs (n: v: builtins.match ".*-linux" v.system != null) hosts) // {
        default = self.nixosConfigurations.${detectHost} or self.nixosConfigurations."ryzen-pop";
      };
    };
}
