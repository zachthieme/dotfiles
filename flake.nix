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
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      minimal-tmux,
      ...
    }:
    let
      lib = nixpkgs.lib;
      hostData = import ./modules/hosts/definitions.nix { inherit lib; };
      detectHostData = import ./modules/hosts/detect.nix { inherit (hostData) hosts; };
      mkDarwinConfig = import ./modules/darwin/mk-config.nix { inherit nix-darwin home-manager minimal-tmux; };
      mkHomeConfig = import ./modules/home-manager/mk-config.nix {
        inherit home-manager minimal-tmux nixpkgs;
      };
      inherit (hostData) hosts darwinHosts linuxHosts;
      defaultHost = detectHostData.defaultHost;
      darwinConfigs = builtins.mapAttrs mkDarwinConfig darwinHosts;
      linuxConfigs = builtins.mapAttrs mkHomeConfig linuxHosts;
    in
    {
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
