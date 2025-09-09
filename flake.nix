{
  description = "Nix-darwin + Home Manager setup for Mac and Linux machines";

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

    # Optional flake inputs
    minimal-tmux = {
      url = "github:niksingh710/minimal-tmux-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nix-darwin, home-manager, minimal-tmux, ... }:
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
        "srv722852" = {
          system = "x86_64-linux";
          user = "zach";
          isWork = false;
          packages = []; # Add any host-specific packages here
        };
      };

      darwinHosts = builtins.filterAttrs (_: host: builtins.match ".*-darwin" host.system != null) hosts;
      linuxHosts = builtins.filterAttrs (_: host: builtins.match ".*-linux" host.system != null) hosts;

      # Helper function to create Darwin configurations
      mkDarwinConfig = hostname: { system, user, isWork, packages ? [], ... }:
        let
          # Context-specific files
          contextModule = if isWork then ./home-manager/work.nix else ./home-manager/home.nix;
          # Architecture-specific module
          archModule = if system == "aarch64-darwin" then ./overlays/arch/aarch64.nix else ./overlays/arch/x86_64.nix;
          # Context-specific module
          contextSystemModule = if isWork then ./overlays/context/work.nix else ./overlays/context/home.nix;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            # Base system configuration
            ./base/default.nix

            # OS-specific overrides
            ./overlays/os/darwin.nix

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
              home-manager.users.${user} = import contextModule;
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
          isWork = builtins.match "zthieme.*" hostname != null;
        in
          if builtins.hasAttr hostname hosts then
            hostname
          else if isWork then
            "zthieme34911"
          else if isAarch64 then
            "cortex"
          else
            "malv2";
      mkHomeConfig = hostname: { system, user, isWork, packages ? [], ... }:
        let
          contextModule = if isWork then ./home-manager/work.nix else ./home-manager/home.nix;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            contextModule
            { home.packages = packages; }
          ];
          extraSpecialArgs = { inherit minimal-tmux; };
        };

      darwinConfigs = builtins.mapAttrs mkDarwinConfig darwinHosts;
      linuxConfigs = builtins.mapAttrs mkHomeConfig linuxHosts;
    in
    {
      darwinConfigurations =
        darwinConfigs //
        (if builtins.hasAttr detectHost darwinConfigs then { default = darwinConfigs.${detectHost}; } else {});
      homeConfigurations = linuxConfigs;
    };
}
