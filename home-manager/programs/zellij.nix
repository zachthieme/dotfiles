# Zellij terminal multiplexer configuration
{ config, ... }:

{
  # Enable catppuccin theme for zellij (inherits flavor from global catppuccin.flavor)
  catppuccin.zellij.enable = true;

  programs.zellij = {
    enable = true;

    settings = {
      default_layout = "compact-top";
      default_shell = "fish";
      pane_frames = false;
      show_startup_tips = false;

      keybinds = {
        shared = {
          # removed to not conflict with alt right in fish
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
