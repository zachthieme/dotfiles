# Jujutsu (jj) VCS configuration
{ ... }:

{
  programs.jujutsu = {
    enable = true;
    settings = {
      aliases = {
        s = [ "show" "--name-only" ];
        b = [ "bookmark" "move" "main" "--to" "@-" ];
        l = [ "log" "-r" "::" "--limit" "20" ];
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
