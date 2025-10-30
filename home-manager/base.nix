# Base Home Manager configuration shared across all users
{
  config,
  pkgs,
  minimal-tmux ? null,
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
    ".config/bat".source = ../config/bat;
    ".config/borders".source = ../config/borders;
    ".config/btop".source = ../config/btop;
    ".config/doom".source = ../config/doom;
    ".config/fzf".source = ../config/fzf;
    ".config/ghostty".source = ../config/ghostty;
    ".config/helix".source = ../config/helix;
    ".config/jj".source = ../config/jj;
    ".config/lazygit".source = ../config/lazygit;
    ".config/nvim-gpt".source = ../config/nvim-gpt;
    ".config/nvim-notes".source = ../config/nvim-notes;
    ".config/nvim".source = ../config/nvim;
    ".config/ohmyposh".source = ../config/ohmyposh;
    ".config/wezterm".source = ../config/wezterm;
    ".config/zed".source = ../config/zed;
    ".config/zsh".source = ../config/zsh;
    ".terminfo/x/xterm-ghostty".source = ../config/terminfo/x/xterm-ghostty;
    # "./.ssh".source = ../config/ssh;
    # ".config/cheat".source = ../config/cheat;
    # ".config/direnv".source = ../config/direnv;
    # ".config/emacs".source = ../config/emacs;
    # ".config/gh".source = ../config/gh;
    # ".config/jrnl".source = ../config/jrnl;
    # ".config/nvim-obsidian".source = .../config/nvim-obsidian;
    # ".config/nvim-test".source = ../config/nvim-test;
    # ".config/raycast".source = ../config/raycast;
    # ".config/skhd".source = ../config/skhd;
    # ".config/spotify-player".source = ../config/spotify-player;
    # ".config/yabai".source = ../config/yabai;
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    shortcut = "a";
    aggressiveResize = true;
    escapeTime = 0;
    clock24 = true;

    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      continuum
      nord
      resurrect
      vim-tmux-navigator
      # minimal-tmux can be passed in from the user config
      # tmuxPlugins.catppuccin
      # tmuxPlugins.rose-pine
      # tmuxPlugins.sensible
    ];

    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides "tmux-256color"
      set-option -g focus-events on
      set -g mode-keys vi
      set -g default-command ${pkgs.zsh}/bin/zsh

      set-option -g status-position top
      set-option -g renumber-windows on

      set -g @resurrect-capture-pane-contents 'on'
      # Enable auto-save and auto-restore
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'

      set -g mouse on

      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # set -g "arcticicestudio/nord-tmux"
    '';
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = false;
    completionInit = ''
      if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
          compinit
      else
          compinit -C
      fi
    '';

    shellAliases = {
      c = "clear";
      cat = "bat";
      emacs = "emacs -nw";
      ft = ''fzf-tmux --height 70% -- fzf --preview="cat --color=always {}" --preview-window=right:50% --border'';
      # gs = "git status";
      j = "z";
      ll = "eza -lah";
      mkdir = "mkdir -p";
      t = ''tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'';
      # tmux = "tmux -u -f ~/.config/tmux/tmux.conf";
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

       # used to load carapace
       export CARAPACE_BRIDGES='zsh,bash,inshellisense' # optional
       zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
       source <(carapace _carapace)

      # FZF location mode (Ctrl-L) -------------------------------------
       function _fzf_loc_widget() {
         local dest
         dest=$(
           zoxide query -ls |   
             awk '{$1=""; sub(/^ +/,""); print}' |
             fzf --tac                      \
                 --prompt='dir> '           \
                 --height=40% --reverse     \
                 --preview 'exa -aT --level=2 {} 2>/dev/null | head -100'
         ) || return

         [[ -n $dest ]] && builtin cd "$dest"
         zle reset-prompt      
       }

       zle -N fzf-loc _fzf_loc_widget
       bindkey -M viins '^L' fzf-loc
       bindkey -M vicmd '^L' fzf-loc

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

  home.packages =
    packageProfiles.profiles.basePackages
    ++ (with pkgs; [
      oh-my-posh
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-vi-mode
    ]);
}
