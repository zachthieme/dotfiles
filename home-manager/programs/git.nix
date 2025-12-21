# Git configuration
#
# User identity is configured in modules/hosts/definitions.nix per host.
# Most hosts use the default identity; override per-host if needed.
{ config, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = config.dotfiles.git.name;
        email = config.dotfiles.git.email;
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
