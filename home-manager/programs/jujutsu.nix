# Jujutsu (jj) VCS configuration
#
# User identity is configured in modules/hosts/definitions.nix per host.
# Most hosts use the default identity; override per-host if needed.
{ config, ... }:

{
  programs.jujutsu = {
    enable = true;
    settings = {
      aliases = {
        b = [ "bookmark" "move" "main" "--to" "@-" ];
        c = [ "commit" "-m" ];
        l = [ "log" "-r" "::" "--limit" "10" ];
        ll = [ "log" "-r" "::" "--limit" "25" ];
        lll = [ "log" "-r" "::" "--limit" "50" ];
        r = ["rebase" "-d"];
        s = [ "show" "--name-only" ];
      };
      user = {
        name = config.dotfiles.vcs.name;
        email = config.dotfiles.vcs.email;
      };
      ui = {
        default-command = "log";
        pager = "delta";
        diff-formatter = [ "delta" "--color-only" ];
      };
    };
  };
}
