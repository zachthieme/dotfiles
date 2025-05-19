{
  config,
  pkgs,
  ...
}:

{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = "/Users/${config.home.username}";
  home.stateVersion = "25.05"; # Adjust based on your nixpkgs version
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    FZF_CTRL_T_OPTS = "--height 20%";
    FZF_CTRL_R_OPTS = "--height 20% --reverse";
    _ZO_FZF_OPTS = "--height 20% --reverse";
  };

  # home.file = {
  #   ".config/aerospace".source = ./aerospace;
  #   ".config/bat".source = ./bat;
  #   ".config/btop".source = ./btop;
  #   ".config/cheat".source = ./cheat;
  #   ".config/direnv".source = ./direnv;
  #   ".config/doom".source = ./doom;
  #   ".config/emacs".source = ./emacs;
  #   ".config/fzf".source = ./fzf;
  #   ".config/gh".source = ./gh;
  #   ".config/ghostty".source = ./ghostty;
  #   ".config/helix".source = ./helix;
  #   ".config/lazygit".source = ./lazygit;
  #   ".config/nvim".source = ./nvim;
  #   ".config/nvim-notes".source = ./nvim-notes;
  #   ".config/nvim-obsidian".source = ./nvim-obsidian;
  #   ".config/nvim-test".source = ./nvim-test;
  #   ".config/ohmyposh".source = ./ohmyposh;
  #   ".config/raycast".source = ./raycast;
  #   ".config/sketchybar".source = ./sketchybar;
  #   ".config/skhd".source = ./skhd;
  #   ".config/spotify-player".source = ./spotify-player;
  #   ".config/tmux".source = ./tmux;
  #   ".config/wezterm".source = ./wezterm;
  #   ".config/yabai".source = ./yabai;
  #   ".config/zed".source = ./zed;
  #   ".config/zsh".source = ./zsh;
  # };

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
