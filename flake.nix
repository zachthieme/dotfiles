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

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      catppuccin,
      ...
    }:
    let
      lib = nixpkgs.lib;
      helpers = import ./modules/lib.nix { inherit lib; };
      hostData = import ./modules/hosts/definitions.nix { inherit lib helpers; };
      detectHostData = import ./modules/hosts/detect.nix { inherit (hostData) hosts; };
      mkDarwinConfig = import ./modules/darwin/mk-config.nix {
        inherit nix-darwin home-manager catppuccin helpers;
      };
      mkHomeConfig = import ./modules/home-manager/mk-config.nix {
        inherit home-manager nixpkgs catppuccin helpers;
      };
      inherit (hostData) hosts darwinHosts linuxHosts;
      defaultHost = detectHostData.defaultHost;
      darwinConfigs = builtins.mapAttrs mkDarwinConfig darwinHosts;
      linuxConfigs = builtins.mapAttrs mkHomeConfig linuxHosts;
    in
    {
      # Expose hosts for validation in install.sh
      inherit hosts;

      darwinConfigurations =
        darwinConfigs
        // (
          if builtins.hasAttr defaultHost darwinConfigs then
            { default = darwinConfigs.${defaultHost}; }
          else
            { }
        );
      homeConfigurations = linuxConfigs;
    };
}
