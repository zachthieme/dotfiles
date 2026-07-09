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

    catppuccin = {
      url = "github:catppuccin/nix";
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

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    catppuccin,
    claude-code,
    pike,
    tick,
    wen,
    grove,
    herdr,
    ...
  }: let
    lib = nixpkgs.lib;
    helpers = import ./lib.nix {inherit lib;};
    mkOverlay = name: input: final: _prev: {
      ${name} = input.packages.${final.stdenv.hostPlatform.system}.default;
    };
    customOverlays = [
      (mkOverlay "claude-code" claude-code)
      (mkOverlay "grove" grove)
      (mkOverlay "herdr" herdr)
      (mkOverlay "pike" pike)
      (mkOverlay "tick" tick)
      (mkOverlay "wen" wen)
    ];
    hostData = import ./hosts/definitions.nix {inherit lib helpers;};
    mkDarwinConfig = import ./builders/darwin.nix {
      inherit nix-darwin home-manager catppuccin helpers customOverlays;
    };
    mkHomeConfig = import ./builders/home-manager.nix {
      inherit home-manager nixpkgs catppuccin helpers customOverlays;
    };
    inherit (hostData) hosts darwinHosts linuxHosts;
    darwinConfigs = builtins.mapAttrs mkDarwinConfig darwinHosts;
    linuxConfigs = builtins.mapAttrs mkHomeConfig linuxHosts;
  in {
    # Expose hosts for validation in install.sh
    # (under lib because top-level custom outputs trip `nix flake check` warnings)
    lib = {inherit hosts;};

    # Hermetic tests, run by `nix flake check` locally and in CI.
    # Linux-only: the notes test needs uuidgen (util-linux), which nixpkgs
    # doesn't ship for darwin; darwin CI covers evaluation instead.
    checks = lib.genAttrs ["x86_64-linux" "aarch64-linux"] (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        fish-functions =
          pkgs.runCommand "fish-functions-check" {
            nativeBuildInputs = with pkgs; [
              coreutils
              fd
              findutils
              fish
              gawk
              git
              gnugrep
              jujutsu
              ripgrep
              util-linux
            ];
          } ''
            export HOME=$TMPDIR
            # jj identity for the notes-sync tests (no user config in the sandbox)
            export JJ_USER=nix-check JJ_EMAIL=check@example.invalid
            fish -n ${./config/fish/functions}/*.fish ${./config/fish/functions}/darwin/*.fish
            fish -C "set -p fish_function_path ${./config/fish/functions}" -c notes-test
            touch $out
          '';

        # Shell scripts have no other automated coverage — lint install.sh (the
        # bootstrap path) and scripts/review.sh (the rubric checker) so shell
        # regressions fail `nix flake check`
        install-script =
          pkgs.runCommand "install-script-check" {
            nativeBuildInputs = with pkgs; [shellcheck];
          } ''
            shellcheck --severity=warning ${./install.sh} ${./scripts/review.sh} ${./scripts/check-eval.sh}
            touch $out
          '';
      }
    );

    # Formatter for `nix fmt` (CLAUDE.md: run before every commit)
    # Wrapped because newer nix invokes the formatter with no arguments,
    # and bare alejandra would then read stdin instead of the tree
    formatter = lib.genAttrs ["aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux"] (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.writeShellScriptBin "alejandra-tree" ''exec ${pkgs.alejandra}/bin/alejandra "''${@:-.}"''
    );

    darwinConfigurations = darwinConfigs;
    homeConfigurations = linuxConfigs;
  };
}
