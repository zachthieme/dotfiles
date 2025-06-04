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
    # "./.ssh".source = ../../config/ssh;
    ".config/aerospace".source = ../../config/aerospace;
    ".config/bat".source = ../../config/bat;
    ".config/btop".source = ../../config/btop;
    # ".config/doom".source = ../../config/doom;
    # ".config/emacs".source = ../../config/emacs;
    ".config/fzf".source = ../../config/fzf;
    ".config/ghostty".source = ../../config/ghostty;
    ".config/lazygit".source = ../../config/lazygit;
    ".config/nvim-notes".source = ../../config/nvim-notes;
    ".config/nvim-obsidian".source = ../../config/nvim-obsidian;
    ".config/nvim".source = ../../config/nvim;
    ".config/ohmyposh".source = ../../config/ohmyposh;
    ".config/sketchybar".source = ../../config/sketchybar;
    # ".config/tmux".source = ../../config/tmux;
    ".config/wezterm".source = ../../config/wezterm;
    ".config/zsh".source = ../../config/zsh;
    # ".config/cheat".source = ../../config/cheat;
    # ".config/direnv".source = ../../config/direnv;
    # ".config/gh".source = ../../config/gh;
    # ".config/helix".source = ../../config/helix;
    # ".config/nvim-test".source = ../../config/nvim-test;
    # ".config/raycast".source = ../../config/raycast;
    # ".config/skhd".source = ../../config/skhd;
    # ".config/spotify-player".source = ../../config/spotify-player;
    # ".config/yabai".source = ../../config/yabai;
    # ".config/zed".source = ../../config/zed;
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    shortcut = "a";
    aggressiveResize = true;
    escapeTime = 0;
    clock24 = true;

    plugins = with pkgs; [
      # {
      #   plugin = minimal-tmux.packages.${pkgs.system}.default;
      # }
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.catppuccin
      # tmuxPlugins.rose-pine
      # tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
    ];

    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides "tmux-256color"

      set -g default-command ${pkgs.zsh}/bin/zsh

      set-option -g status-position top
      set-option -g renumber-windows on

      set -g mouse on
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      set -g @catppuccin_flavour 'mocha'
    '';
  };
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = false;

    shellAliases = {
      c = "clear";
      cat = "bat";
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
      #make sure brew is on the path for M1 
      if [[ $(uname -m) == 'arm64' ]]; then
         eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
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
