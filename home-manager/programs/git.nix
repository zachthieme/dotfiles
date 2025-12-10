# Git configuration
#
# Note: Email is intentionally hardcoded to personal address for all machines.
# Work commits should use personal identity (open source contributor model).
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
      side-by-side = true;
    };
  };
}
