{
  config,
  pkgs,
  purePrompt,
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

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = false;

    shellAliases = {
      ll = "eza -lah";
      gs = "git status";
      cm = "chezmoi";
      c = "clear";
      ch = ''cheat -l | awk "{print \\$1}" | fzf --preview "cheat --colorize {1}" --preview-window=right,70%'';
      emacs = "emacs -nw";
      j = "z";
      mkdir = "mkdir -p";
      tmux = "tmux -u -f ~/.config/tmux/tmux.conf";
      t = ''tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'';
      vi = "nvim";
      v = "/usr/bin/vi";
      ft = ''fzf-tmux --height 70% -- fzf --preview="cat --color=always {}" --preview-window=right:50% --border'';

      notes = ''NVIM_APPNAME=$(basename nvim-notes) nvim'';
      norg = ''NVIM_APPNAME=$(basename nvim-norg) nvim'';

    };

    initExtra = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      fpath+=("${purePrompt}/share/zsh/site-functions")
      autoload -U promptinit; promptinit
      prompt pure
    '';

    initContent = ''
      # Fish-like prompt
      autoload -Uz promptinit; promptinit
      prompt pure

      # fzf keybindings
      [ -f ${pkgs.fzf}/share/fzf/key-bindings.zsh ] && source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      [ -f ${pkgs.fzf}/share/fzf/completion.zsh ] && source ${pkgs.fzf}/share/fzf/completion.zsh
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
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
    chezmoi
    fzf
    fd
    eza
    bat
    git
    zoxide
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-vi-mode
  ];
}
