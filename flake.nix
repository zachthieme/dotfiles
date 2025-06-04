{
  description = "Nix-darwin + Home Manager setup for multiple MacBooks";

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
        "cortex-m4" = {
          system = "aarch64-darwin";
          user = "zach";
          isWork = false;
        };
        "cortex-intel" = {
          system = "x86_64-darwin";
          user = "zach";
          isWork = false;
        };
        "zthieme34911" = {
          system = "aarch64-darwin";
          user = "zthieme";
          isWork = true;
        };
      };
      
      # Helper function to create Darwin configurations
      mkDarwinConfig = hostname: { system, user, isWork, ... }: 
        let
          # Context-specific files
          contextModule = if isWork then ./home-manager/work.nix else ./home-manager/home.nix;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            # System configuration
            ./hosts/${if isWork then "work-m1" else if system == "aarch64-darwin" then "home-m4" else "home-intel"}/default.nix
            
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
            "cortex-m4"
          else
            "cortex-intel";
    in
    {
      darwinConfigurations = builtins.mapAttrs mkDarwinConfig hosts // {
        default = self.darwinConfigurations.${detectHost};
      };
    };
}