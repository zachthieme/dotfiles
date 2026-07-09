# Base Home Manager configuration shared across all users
{
  config,
  pkgs,
  lib,
  ...
}: let
  packageProfiles = import ../packages/common.nix {inherit pkgs;};
  p = packageProfiles.profiles;

  # Map profile names to package lists
  profilePackages = {
    "core" = p.corePackages;
    "core+dev" = p.corePackages ++ p.devPackages;
    "full" = p.fullPackages;
  };
in {
  # Custom options for dotfiles-specific settings
  options.dotfiles = {
    vcs = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "VCS user name for commits (git, jj)";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "VCS user email for commits (git, jj)";
      };
    };
    packageProfile = lib.mkOption {
      type = lib.types.enum ["core" "core+dev" "full"];
      default = "full";
      description = "Package profile tier: core (minimal), core+dev (with dev tools), full (everything)";
    };
    notesDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/CloudDocs/Notes";
      description = "Notes directory — single source of truth for the NOTES env var, pike, and workspace layouts";
    };
  };

  imports = [
    ./programs/bat.nix
    ./programs/btop.nix
    ./programs/fish
    ./programs/ghostty.nix
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/jujutsu.nix
    ./programs/lazygit.nix
    ./programs/neovim.nix
    ./programs/pike.nix
    ./programs/ssh.nix
    ./programs/tmux.nix
    ./programs/wen.nix
    ./programs/zellij.nix
  ];

  config = {
    # Catppuccin theming (global enable applies to all supported programs)
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "sky";
    };

    home.stateVersion = "25.05"; # Do NOT change after initial install — pins state migration behavior, not the nixpkgs version

    # Disable news notifications
    news.display = "silent";

    # Nix settings for optimal performance and caching
    # Shared settings apply to both platforms; Linux adds nix management extras
    # macOS: Determinate Nix manages the daemon, so we only set user-level options
    nix = {
      package = pkgs.nix;
      settings =
        {
          max-jobs = "auto";
          download-buffer-size = 256 * 1024 * 1024; # 256 MiB
          extra-substituters = [
            "https://claude-code.cachix.org"
            "https://nix-community.cachix.org"
          ];
          extra-trusted-public-keys = [
            "claude-code.cachix.org-1:LSMRqGJFczEaKDBoXDjZnJpnaFRHBaGW/g8TMC3oFwA="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        }
        // lib.optionalAttrs pkgs.stdenv.isLinux {
          experimental-features = ["nix-command" "flakes"];
          auto-optimise-store = true;
        };
    };

    home.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
      CARGO_TARGET_DIR = "${config.home.homeDirectory}/.cache/cargo-target";
      COLORTERM = "truecolor";
      NOTES = config.dotfiles.notesDir;
      OBSIDIAN_VAULT = "${config.home.homeDirectory}/CloudDocs/Obsidian";
      _ZO_FZF_OPTS = "--height 20% --reverse";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
    };

    # PATH additions
    # - macOS: Homebrew is at /opt/homebrew/bin on Apple Silicon
    # - Linux: the Home Manager bin path is NOT listed here — sessionPath appends,
    #   but that path must shadow system dirs, so fish prepends it in shellInit
    #   (programs/fish/default.nix) and install.sh prepends it in .bashrc
    home.sessionPath =
      [
        "${config.home.homeDirectory}/.local/bin"
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin ["/opt/homebrew/bin"];

    # This will be imported by user-specific configurations
    # These paths are relative to the root dotfiles directory
    home.file =
      {
        # markdown-oxide config goes in the notes vault root, wherever
        # dotfiles.notesDir points (home.file keys are home-relative, so
        # notesDir must live under the home directory)
        "${lib.removePrefix "${config.home.homeDirectory}/" config.dotfiles.notesDir}/.moxide.toml".source = ../config/moxide/.moxide.toml;
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        ".config/aerospace".source = ../config/aerospace;
        ".config/borders".source = ../config/borders;
        ".terminfo".source = ../config/terminfo;
      };

    # Copy jrnl config only if it doesn't exist (jrnl needs to write to its config)
    home.activation.jrnlConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f ~/.config/jrnl/jrnl.yaml ]; then
        mkdir -p ~/.config/jrnl
        cp ${../config/jrnl/jrnl.yaml} ~/.config/jrnl/jrnl.yaml
        chmod 644 ~/.config/jrnl/jrnl.yaml
      fi
    '';

    # Simple program configs kept inline
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--smart-case"
        "--hidden"
        "--glob=!.git/*"
        "--glob=!.jj/*"
        "--glob=!node_modules/*"
        "--glob=!.direnv/*"
      ];
    };

    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f";
      defaultOptions = [
        "--height 40%"
        "--border"
      ];
      fileWidgetOptions = ["--height 20%"];
      historyWidgetOptions = ["--height 20%" "--reverse"];
      enableFishIntegration = true;
    };

    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = ''
        use_devenv() {
          watch_file devenv.nix
          watch_file devenv.lock
          watch_file devenv.yaml
          eval "$(devenv print-dev-env --impure)"
        }
      '';
    };

    programs.carapace = {
      enable = true;
      enableFishIntegration = true;
    };

    # Select packages based on profile
    home.packages = profilePackages.${config.dotfiles.packageProfile};
  };
}
