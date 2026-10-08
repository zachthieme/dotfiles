{
  description = "Nix-darwin + Home Manager setup for Mac and Linux machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Shared plumbing. Every tool input below pins its own copy of flake-utils
    # (and flake-utils its own nix-systems), which meant five identical
    # `systems` nodes in flake.lock and five churn lines on every update.
    # Pointing them all here collapses that to one node each.
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    # Current nix-systems/default drops x86_64-darwin, so the four tool flakes
    # that used to pin a 2023 copy no longer expose `packages.x86_64-darwin`.
    # Inert today (no Intel Mac in hosts/definitions.nix); if one is ever added,
    # pin this back to da67096 or the tool overlays will fail on a missing attr.
    systems.url = "github:nix-systems/default";

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
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tick = {
      url = "github:zachthieme/tick";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wen = {
      url = "github:zachthieme/wen";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };

    grove = {
      url = "github:zachthieme/grove";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # HEY email CLI. Deliberately NOT following our nixpkgs: it builds with
    # go_1_27 and go.mod requires >= 1.27.0, but our pin only has 1.27rc2, which
    # the Go toolchain rejects. Its own lock costs a second nixpkgs eval; add
    # `inputs.nixpkgs.follows = "nixpkgs";` once `install.sh -f` brings a final 1.27.
    hey-cli.url = "github:basecamp/hey-cli";
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
    hey-cli,
    ...
  }: let
    lib = nixpkgs.lib;
    helpers = import ./lib.nix {inherit lib;};
    mkOverlay = name: input: final: _prev: {
      ${name} = input.packages.${final.stdenv.hostPlatform.system}.default;
    };
    # herdr comes from nixpkgs (cached on every platform we build for), so it
    # tracks `install.sh -f` instead of needing a hand-maintained version + hash
    # per platform. It lags upstream releases by however long nixpkgs takes.
    customOverlays = [
      (mkOverlay "claude-code" claude-code)
      (mkOverlay "grove" grove)
      # Not "hey": nixpkgs already has a `hey` (an HTTP load generator)
      (mkOverlay "hey-cli" hey-cli)
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
    checks = lib.genAttrs helpers.linuxSystems (
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
            # jj identity for the notes-sync tests (no user config in the
            # sandbox). The tests own the rest of their hermeticity: they create
            # bare remotes with an explicit `-b main`, so they don't depend on
            # the runner's git config.
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

        # The Voice Memos transcriber (home-manager/programs/voice-memos.nix) only
        # runs on a mac, but writeShellApplication shellchecks it at build time on
        # any platform. A dummy model path keeps the 1.6 GB download out of CI.
        transcribe-memos = pkgs.callPackage ./packages/transcribe-memos.nix {
          model = "/nonexistent/ggml-large-v3-turbo.bin";
        };

        # Runtime coverage beyond lint: actually execute install.sh's arg-parsing
        # path (--help exits before any nix/curl/sudo work) so a regression in the
        # early script structure fails `nix flake check`, not a fresh machine.
        install-smoke = pkgs.runCommand "install-smoke-check" {} ''
          help=$(${pkgs.bash}/bin/bash ${./install.sh} --help)
          echo "$help" | grep -q "Usage:" || { echo "install.sh --help printed no Usage line"; exit 1; }
          echo "$help" | grep -q "flake-update" || { echo "install.sh --help missing -f docs"; exit 1; }
          touch $out
        '';
      }
    );

    # Formatter for `nix fmt` (CLAUDE.md: run before every commit)
    # Wrapped because newer nix invokes the formatter with no arguments,
    # and bare alejandra would then read stdin instead of the tree
    formatter = lib.genAttrs helpers.supportedSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.writeShellScriptBin "alejandra-tree" ''exec ${pkgs.alejandra}/bin/alejandra "''${@:-.}"''
    );

    darwinConfigurations = darwinConfigs;
    homeConfigurations = linuxConfigs;
  };
}
