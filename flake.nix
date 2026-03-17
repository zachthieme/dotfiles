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

    pike = {
      url = "github:zachthieme/pike";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wen = {
      url = "github:zachthieme/wen";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      catppuccin,
      pike,
      wen,
      ...
    }:
    let
      lib = nixpkgs.lib;
      helpers = import ./modules/lib.nix { inherit lib; };
      pikeOverlay = final: prev: {
        pike = pike.packages.${final.system}.default;
      };
      wenOverlay = final: prev: {
        wen = wen.packages.${final.system}.default;
      };
      hostData = import ./modules/hosts/definitions.nix { inherit lib helpers; };
      detectHostData = import ./modules/hosts/detect.nix { inherit (hostData) hosts; };
      mkDarwinConfig = import ./modules/darwin/mk-config.nix {
        inherit nix-darwin home-manager catppuccin helpers pikeOverlay wenOverlay;
      };
      mkHomeConfig = import ./modules/home-manager/mk-config.nix {
        inherit home-manager nixpkgs catppuccin helpers pikeOverlay wenOverlay;
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
