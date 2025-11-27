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
    ./programs/fish.nix
    ./programs/ghostty.nix
    ./programs/helix.nix
    ./programs/jujutsu.nix
    ./programs/lazygit.nix
  ];

  home.stateVersion = "25.05"; # Adjust based on your nixpkgs version

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
    _ZO_FZF_OPTS = "--height 20% --reverse";
  };

  home.sessionPath =
    [ "${config.home.homeDirectory}/.local/bin" ]
    ++ lib.optionals pkgs.stdenv.isDarwin [ "/opt/homebrew/bin" ];

  # This will be imported by user-specific configurations
  # These paths are relative to the root dotfiles directory
  home.file = {
    ".config/aerospace".source = ../config/aerospace;
    ".config/borders".source = ../config/borders;
    ".config/jrnl".source = ../config/jrnl;
    ".config/zellij".source = ../config/zellij;
    ".terminfo/x/xterm-ghostty".source = ../config/terminfo/x/xterm-ghostty;
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
