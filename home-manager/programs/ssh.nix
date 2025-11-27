# SSH configuration
{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };
}
