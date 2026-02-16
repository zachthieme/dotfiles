# Zellij terminal multiplexer configuration
{ config, ... }:

{
  # Enable catppuccin theme for zellij (inherits flavor from global catppuccin.flavor)
  catppuccin.zellij.enable = true;

  programs.zellij = {
    enable = true;

    settings = {
      default_layout = "compact";
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
          # Alt F re-enabled for ToggleFloatingPanes (notes layout)
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

  # Custom layout files - Home Manager doesn't have structured layout options
  xdg.configFile."zellij/layouts/notes.kdl".text = ''
    layout {
        cwd "~/CloudDocs/Notes"
        tab name="notes" {
            pane size=1 borderless=true {
                plugin location="zellij:compact-bar"
            }
            pane size=8 name="tasks" command="fish" {
                args "-c" "fw; exec fish"
            }
            pane name="editor" focus=true command="fish" {
                args "-c" "set -l fp (date +%Y-%m-%d).md; test -e $fp || daily > $fp; exec hx $fp"
            }
            pane size="40%" name="search"
        }
    }
  '';

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
