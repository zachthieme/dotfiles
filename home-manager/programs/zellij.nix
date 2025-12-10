# Zellij terminal multiplexer configuration
{ config, ... }:

{
  programs.zellij = {
    enable = true;

    # Enable catppuccin theme (inherits flavor from global catppuccin.flavor)
    catppuccin.enable = true;

    settings = {
      default_layout = "compact-top";
      default_shell = "fish";
      pane_frames = false;
      show_startup_tips = false;

      keybinds = {
        shared = {
          "unbind \"Alt Right\"" = { };
          "unbind \"Alt F\"" = { };
          # Remove bindings so they don't conflict with helix
          "unbind \"Alt Shift 0\"" = { };
          "unbind \"Alt Shift 1\"" = { };
          "unbind \"Alt Shift 9\"" = { };
        };
        normal = {
          "bind \"Alt h\"" = { MoveFocus = "Left"; };
          "bind \"Alt j\"" = { MoveFocus = "Down"; };
          "bind \"Alt k\"" = { MoveFocus = "Up"; };
          "bind \"Alt l\"" = { MoveFocus = "Right"; };
          "bind \"Alt H\"" = { GoToPreviousTab = { }; };
          "bind \"Alt L\"" = { GoToNextTab = { }; };
        };
      };
    };
  };

  # Custom layout file - Home Manager doesn't have structured layout options
  xdg.configFile."zellij/layouts/compact-top.kdl".text = ''
    layout {
        pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
        }
        pane

        pane size=2 borderless=true {
            plugin location="zellij:status-bar"
        }
    }
  '';
}
