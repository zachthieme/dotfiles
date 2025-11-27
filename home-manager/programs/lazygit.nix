# Lazygit configuration
{ ... }:

{
  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor = [ "#82aaff" "bold" ];
        inactiveBorderColor = [ "#637777" ];
        optionsTextColor = [ "#acb4c2" ];
        selectedLineBgColor = [ "#82aaff" ];
        selectedRangeBgColor = [ "#82aaff" ];
        cherryPickedCommitBgColor = [ "#82aaff" ];
        cherryPickedCommitFgColor = [ "#011627" ];
        unstagedChangesColor = [ "#ef5350" ];
        defaultFgColor = [ "#acb4c2" ];
      };
    };
  };
}
