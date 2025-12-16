# Jujutsu (jj) VCS configuration
#
# Note: Email is intentionally hardcoded to personal address for all machines.
# Work commits should use personal identity (open source contributor model).
{ ... }:

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
        r = ["rebase" "-d" "{0}" "-"];
        s = [ "show" "--name-only" ];
      };
      user = {
        name = "Zach Thieme";
        email = "zach@techsage.org";
      };
      ui = {
        default-command = "log";
        pager = "delta";
        diff.tool = [ "delta" "--color-only" ];
      };
    };
  };
}
