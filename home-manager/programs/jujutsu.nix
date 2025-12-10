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
        s = [ "show" "--name-only" ];
        c = [ "commit" "-m" ];
        b = [ "bookmark" "move" "main" "--to" "@-" ];
        l = [ "log" "-r" "::" "--limit" "10" ];
      };
      user = {
        name = "Zach Thieme";
        email = "zach@techsage.org";
      };
      ui = {
        paginate = "never";
        default-command = "log";
      };
    };
  };
}
