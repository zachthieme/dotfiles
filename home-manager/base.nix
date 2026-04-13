# Base Home Manager configuration shared across all users
{
  config,
  pkgs,
  lib,
  ...
}:

let
  packageProfiles = import ../packages/common.nix { inherit pkgs; };
  p = packageProfiles.profiles;

  # Map profile names to package lists
  profilePackages = {
    "core" = p.corePackages;
    "core+dev" = p.corePackages ++ p.devPackages;
    "full" = p.basePackages;
  };
in
{
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
      type = lib.types.enum [ "core" "core+dev" "full" ];
      default = "full";
      description = "Package profile tier: core (minimal), core+dev (with dev tools), full (everything)";
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
    ./programs/pike.nix
    ./programs/ssh.nix
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

    home.stateVersion = "25.05"; # Adjust based on your nixpkgs version

    # Disable news notifications
    news.display = "silent";

    # Nix settings for optimal performance and caching
    # Shared settings apply to both platforms; Linux adds nix management extras
    # macOS: Determinate Nix manages the daemon, so we only set user-level options
    nix = {
      package = pkgs.nix;
      settings = {
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
      } // lib.optionalAttrs pkgs.stdenv.isLinux {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };
    };

    home.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
      COLORTERM = "truecolor";
      OBSIDIAN_VAULT = "${config.home.homeDirectory}/CloudDocs/Obsidian";
      _ZO_FZF_OPTS = "--height 20% --reverse";
      RIPGREP_CONFIG_PATH = "${config.home.homeDirectory}/.config/ripgrep/config";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
    };

    # PATH additions
    # - Linux: Home Manager standalone puts packages in ~/.local/state/nix/profiles/home-manager/home-path/bin
    #   (unlike macOS where nix-darwin manages paths system-wide)
    # - macOS: Homebrew is at /opt/homebrew/bin on Apple Silicon
    home.sessionPath =
      [
        "${config.home.homeDirectory}/.local/bin"
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [ "/opt/homebrew/bin" ]
      ++ lib.optionals pkgs.stdenv.isLinux [ "${config.home.homeDirectory}/.local/state/nix/profiles/home-manager/home-path/bin" ];

    # This will be imported by user-specific configurations
    # These paths are relative to the root dotfiles directory
    home.file = {
      ".config/aerospace".source = ../config/aerospace;
      ".config/borders".source = ../config/borders;
      ".config/nvim".source = ../config/nvim;
      ".config/ripgrep".source = ../config/ripgrep;
      ".terminfo".source = ../config/terminfo;
      # markdown-oxide config goes in the Obsidian vault root
      "CloudDocs/Obsidian/.moxide.toml".source = ../config/moxide/.moxide.toml;
    };

    # Copy jrnl config only if it doesn't exist (jrnl needs to write to its config)
    home.activation.jrnlConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f ~/.config/jrnl/jrnl.yaml ]; then
        mkdir -p ~/.config/jrnl
        cp ${../config/jrnl/jrnl.yaml} ~/.config/jrnl/jrnl.yaml
        chmod 644 ~/.config/jrnl/jrnl.yaml
      fi
    '';

    # Simple program configs kept inline
    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f";
      defaultOptions = [
        "--height 40%"
        "--border"
      ];
      fileWidgetOptions = [ "--height 20%" ];
      historyWidgetOptions = [ "--height 20%" "--reverse" ];
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
