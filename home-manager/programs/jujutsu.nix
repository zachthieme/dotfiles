# Jujutsu (jj) VCS configuration
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
