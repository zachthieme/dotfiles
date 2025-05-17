{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  programs.zsh = {
    enable = true;
    #    enableCompletion = true;
    #    enableAutosuggestions = true;
    #    enableSyntaxHighlighting = true;

    shellAliases = {
      ll = "ls -la";
      gs = "git status";
      cat = "bat";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
