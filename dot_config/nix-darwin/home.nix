{ config, pkgs, ... }:

{
  home.username = "zach";
  home.homeDirectory = "/Users/zach";
  home.stateVersion = "25.05"; # Adjust based on your nixpkgs version

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = false;

    shellAliases = {
      ll = "eza -lah";
      gs = "git status";
    };

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
    fzf
    fd
    eza
    bat
    git
    zoxide
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];
}
