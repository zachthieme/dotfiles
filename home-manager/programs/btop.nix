# Btop configuration
{ ... }:

{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "everforest-dark-hard";
      theme_background = false;
      vim_keys = true;
    };
  };
}
