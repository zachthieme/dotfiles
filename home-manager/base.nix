# Base Home Manager configuration shared across all users
{
  config,
  pkgs,
  lib,
  ...
}:

let
  packageProfiles = import ../packages/common.nix { inherit pkgs; };
in
{
  imports = [
    ./programs/bat.nix
    ./programs/btop.nix
    ./programs/fish.nix
    ./programs/ghostty.nix
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/jujutsu.nix
    ./programs/lazygit.nix
    ./programs/ssh.nix
    ./programs/zellij.nix
  ];

  # Catppuccin theming (global enable applies to all supported programs)
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "sky";
  };

  home.stateVersion = "25.05"; # Adjust based on your nixpkgs version

  # Disable news notifications
  news.display = "silent";

  # Enable experimental features for nix commands
  # Note: On macOS, nix-darwin manages nix.package at system level
  nix = lib.mkMerge [
    {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
      };
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      package = pkgs.nix;
    })
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    COLORTERM = "truecolor";
    OBSIDIAN_VAULT = "${config.home.homeDirectory}/CloudDocs/Obsidian";
    _ZO_FZF_OPTS = "--height 20% --reverse";
    RIPGREP_CONFIG_PATH = "${config.home.homeDirectory}/.config/ripgrep/config";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };

  # PATH additions
  # - Linux: Home Manager standalone puts packages in ~/.local/state/nix/profiles/home-manager/home-path/bin
  #   (unlike macOS where nix-darwin manages paths system-wide)
  # - macOS: Homebrew is at /opt/homebrew/bin on Apple Silicon
  home.sessionPath =
    [ "${config.home.homeDirectory}/.local/bin" ]
    ++ lib.optionals pkgs.stdenv.isDarwin [ "/opt/homebrew/bin" ]
    ++ lib.optionals pkgs.stdenv.isLinux [ "${config.home.homeDirectory}/.local/state/nix/profiles/home-manager/home-path/bin" ];

  # This will be imported by user-specific configurations
  # These paths are relative to the root dotfiles directory
  home.file = {
    ".config/aerospace".source = ../config/aerospace;
    ".config/borders".source = ../config/borders;
    ".config/jrnl".source = ../config/jrnl;
    ".config/ripgrep".source = ../config/ripgrep;
    ".terminfo/x/xterm-ghostty".source = ../config/terminfo/x/xterm-ghostty;
    # markdown-oxide config goes in the Obsidian vault root
    "CloudDocs/Obsidian/.moxide.toml".source = ../config/moxide/.moxide.toml;
  };

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
  };

  programs.carapace = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages =
    packageProfiles.profiles.basePackages
    ++ (with pkgs; [
    ]);
}
