{
  config,
  pkgs,
  ...
}:

{
  home.username = "zach";
  home.homeDirectory = "/Users/zach";
  home.stateVersion = "25.05"; # Adjust based on your nixpkgs version
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    FZF_CTRL_T_OPTS = "--height 20%";
    FZF_CTRL_R_OPTS = "--height 20% --reverse";
    _ZO_FZF_OPTS = "--height 20% --reverse";
  };

  home.file = {
    ".config/aerospace".source = ./config/aerospace;
    ".config/bat".source = ./config/bat;
    ".config/btop".source = ./config/btop;
    # ".config/cheat".source = ./config/cheat;
    # ".config/direnv".source = ./config/direnv;
    ".config/doom".source = ./config/doom;
    ".config/emacs".source = ./config/emacs;
    ".config/fzf".source = ./config/fzf;
    # ".config/gh".source = ./config/gh;
    ".config/ghostty".source = ./config/ghostty;
    # ".config/helix".source = ./config/helix;
    ".config/lazygit".source = ./config/lazygit;
    ".config/nvim".source = ./config/nvim;
    ".config/nvim-notes".source = ./config/nvim-notes;
    ".config/nvim-obsidian".source = ./config/nvim-obsidian;
    # ".config/nvim-test".source = ./config/nvim-test;
    ".config/ohmyposh".source = ./config/ohmyposh;
    # ".config/raycast".source = ./config/raycast;
    ".config/sketchybar".source = ./config/sketchybar;
    # ".config/skhd".source = ./config/skhd;
    # ".config/spotify-player".source = ./config/spotify-player;
    ".config/tmux".source = ./config/tmux;
    ".config/wezterm".source = ./config/wezterm;
    # ".config/yabai".source = ./config/yabai;
    # ".config/zed".source = ./config/zed;
    ".config/zsh".source = ./config/zsh;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = false;

    shellAliases = {
      c = "clear";
      ch = ''cheat -l | awk "{print \\$1}" | fzf --preview "cheat --colorize {1}" --preview-window=right,70%'';
      cm = "chezmoi";
      emacs = "emacs -nw";
      ft = ''fzf-tmux --height 70% -- fzf --preview="cat --color=always {}" --preview-window=right:50% --border'';
      gs = "git status";
      j = "z";
      ll = "eza -lah";
      mkdir = "mkdir -p";
      t = ''tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'';
      tmux = "tmux -u -f ~/.config/tmux/tmux.conf";
      v = "/usr/bin/vi";
      vi = "nvim";

      notes = ''NVIM_APPNAME=$(basename nvim-notes) nvim'';
      norg = ''NVIM_APPNAME=$(basename nvim-norg) nvim'';
    };

    initContent = ''
      source ~/.config/zsh/functions

      eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"

      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      # Fish-like prompt
      autoload -Uz promptinit; promptinit

      # fzf keybindings
      [ -f ${pkgs.fzf}/share/fzf/key-bindings.zsh ] && source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      [ -f ${pkgs.fzf}/share/fzf/completion.zsh ] && source ${pkgs.fzf}/share/fzf/completion.zsh

      # Ensure fzf widgets are loaded
      autoload -Uz fzf-file-widget fzf-cd-widget fzf-history-widget
      zle -N fzf-file-widget
      zle -N fzf-history-widget

      # Manually bind if not already present
      bindkey -M viins '^R' fzf-history-widget
      bindkey -M viins '^T' fzf-file-widget
      bindkey -M vicmd '^R' fzf-history-widget
      bindkey -M vicmd '^T' fzf-file-widget

      # needed instead of fzf.enableZshIntegration = true so zsh-vi-mode and fzf do not conflict
      zvm_after_init_commands+=(eval "$(fzf --zsh)")
    '';
  };

  programs.fzf = {
    enable = true;
    # enableZshIntegration = true;
    defaultCommand = "fd --type f";
    defaultOptions = [
      "--height 40%"
      "--border"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    oh-my-posh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-vi-mode
  ];
}
