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
          "unbind \"Alt Left\"" = { };
          "unbind \"Alt Up\"" = { };
          "unbind \"Alt Down\"" = { };
          "unbind \"Alt F\"" = { };
          # Remove bindings so they don't conflict with helix
          "unbind \"Alt Shift 0\"" = { };
          "unbind \"Alt Shift 1\"" = { };
          "unbind \"Alt Shift 9\"" = { };
        };
        normal = {
          # Pane focus with tab fallback (moves to adjacent pane, or switches tab if none)
          "bind \"Alt h\"" = { MoveFocusOrTab = "Left"; };
          "bind \"Alt j\"" = { MoveFocusOrTab = "Down"; };
          "bind \"Alt k\"" = { MoveFocusOrTab = "Up"; };
          "bind \"Alt l\"" = { MoveFocusOrTab = "Right"; };
          # Tab switching by number
          "bind \"Alt 1\"" = { GoToTab = 1; };
          "bind \"Alt 2\"" = { GoToTab = 2; };
          "bind \"Alt 3\"" = { GoToTab = 3; };
          "bind \"Alt 4\"" = { GoToTab = 4; };
          "bind \"Alt 5\"" = { GoToTab = 5; };
          "bind \"Alt 6\"" = { GoToTab = 6; };
          "bind \"Alt 7\"" = { GoToTab = 7; };
          "bind \"Alt 8\"" = { GoToTab = 8; };
          "bind \"Alt 9\"" = { GoToTab = 9; };
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
