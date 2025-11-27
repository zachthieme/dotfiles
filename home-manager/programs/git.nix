# Git configuration
{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Zach Thieme";
    userEmail = "zach@techsage.org";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "base16";
      };
    };
  };
}
