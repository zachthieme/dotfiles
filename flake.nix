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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pike = {
      url = "github:zachthieme/pike";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tick = {
      url = "github:zachthieme/tick";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wen = {
      url = "github:zachthieme/wen";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grove = {
      url = "github:zachthieme/grove";
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
      nixvim,
      claude-code,
      pike,
      tick,
      wen,
      grove,
      ...
    }:
    let
      lib = nixpkgs.lib;
      helpers = import ./modules/lib.nix { inherit lib; };
      mkOverlay = name: input: final: _prev: {
        ${name} = input.packages.${final.stdenv.hostPlatform.system}.default;
      };
      customOverlays = [
        (mkOverlay "claude-code" claude-code)
        (mkOverlay "grove" grove)
        (mkOverlay "pike" pike)
        (mkOverlay "tick" tick)
        (mkOverlay "wen" wen)
      ];
      hostData = import ./modules/hosts/definitions.nix { inherit lib helpers; };
      detectHostData = import ./modules/hosts/detect.nix { inherit (hostData) hosts; };
      mkDarwinConfig = import ./modules/darwin/mk-config.nix {
        inherit nix-darwin home-manager catppuccin nixvim helpers customOverlays;
      };
      mkHomeConfig = import ./modules/home-manager/mk-config.nix {
        inherit home-manager nixpkgs catppuccin nixvim helpers customOverlays;
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
