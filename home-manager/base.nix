# Base Home Manager configuration shared across all users
{
  config,
  pkgs,
  ...
}:

let
  packageProfiles = import ../packages/common.nix { inherit pkgs; };
in
{
  home.stateVersion = "25.05"; # Adjust based on your nixpkgs version

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    FZF_CTRL_T_OPTS = "--height 20%";
    FZF_CTRL_R_OPTS = "--height 20% --reverse";
    _ZO_FZF_OPTS = "--height 20% --reverse";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  # This will be imported by user-specific configurations
  # These paths are relative to the root dotfiles directory
  home.file = {
    ".config/aerospace".source = ../config/aerospace;
    ".config/borders".source = ../config/borders;
    ".config/btop".source = ../config/btop;
    ".config/fzf".source = ../config/fzf;
    ".config/ghostty/config".text = ''
      command = ${pkgs.fish}/bin/fish
      keybind = global:ctrl+grave_accent=toggle_quick_terminal
      quick-terminal-animation-duration = 0
    '';
    ".config/helix".source = ../config/helix;
    ".config/jj".source = ../config/jj;
    ".config/lazygit".source = ../config/lazygit;
    ".config/nvim".source = ../config/nvim;
    ".config/wezterm".source = ../config/wezterm;
    ".config/zed".source = ../config/zed;
    ".config/zellij".source = ../config/zellij;
    ".config/zsh".source = ../config/zsh;
    ".terminfo/x/xterm-ghostty".source = ../config/terminfo/x/xterm-ghostty;
    # "./.ssh".source = ../config/ssh;
    # ".config/bat".source = ../config/bat;
    # ".config/cheat".source = ../config/cheat;
    # ".config/direnv".source = ../config/direnv;
    # ".config/doom".source = ../config/doom;
    # ".config/emacs".source = ../config/emacs;
    # ".config/gh".source = ../config/gh;
    # ".config/jrnl".source = ../config/jrnl;
    # ".config/nvim-gpt".source = ../config/nvim-gpt;
    # ".config/nvim-notes".source = ../config/nvim-notes;
    # ".config/nvim-obsidian".source = .../config/nvim-obsidian;
    # ".config/nvim-test".source = ../config/nvim-test;
    # ".config/ohmyposh".source = ../config/ohmyposh;
    # ".config/raycast".source = ../config/raycast;
    # ".config/skhd".source = ../config/skhd;
    # ".config/spotify-player".source = ../config/spotify-player;
    # ".config/yabai".source = ../config/yabai;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f";
    defaultOptions = [
      "--height 40%"
      "--border"
    ];
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

  home.packages =
    packageProfiles.profiles.basePackages
    ++ (with pkgs; [
    ]);
}
