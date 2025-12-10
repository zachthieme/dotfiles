# Bat configuration
{ ... }:

{
  programs.bat = {
    enable = true;
    config = {
      force-colorization = true;
      style = "numbers,changes,header";
      pager = "less -FR";
    };
  };
}
