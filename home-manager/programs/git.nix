# Git configuration
{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Zach Thieme";
        email = "zach@techsage.org";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      credential.helper = "!gh auth git-credential";
    };
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "base16";
    };
  };
}
