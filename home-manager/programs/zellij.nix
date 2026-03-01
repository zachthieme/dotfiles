# Zellij terminal multiplexer configuration
{ config, ... }:

let
  # Shared keybinds KDL block embedded in layout files.
  # Layouts launched via --layout may not inherit config.kdl keybinds
  # (https://github.com/zellij-org/zellij/issues/4256), so we embed them directly.
  # Pane navigation goes in shared_except "locked" to match the default scope and
  # cleanly replace the defaults. Putting them in "shared" creates a cross-scope
  # collision with the defaults' shared_except "locked" bindings for Alt j/k
  # (which use MoveFocus, not MoveFocusOrTab), causing those keys to silently fail.
  sharedKeybinds = ''
    keybinds {
        shared_except "locked" {
            unbind "Alt Right"
            unbind "Alt Left"
            unbind "Alt Up"
            unbind "Alt Down"
            bind "Alt h" { MoveFocusOrTab "Left"; }
            bind "Alt j" { MoveFocus "Down"; }
            bind "Alt k" { MoveFocus "Up"; }
            bind "Alt l" { MoveFocusOrTab "Right"; }
        }
        shared {
            unbind "Alt Shift 0"
            unbind "Alt Shift 1"
            unbind "Alt Shift 2"
            unbind "Alt Shift 3"
            unbind "Alt Shift 4"
            unbind "Alt Shift 5"
            unbind "Alt Shift 6"
            unbind "Alt Shift 7"
            unbind "Alt Shift 8"
            unbind "Alt Shift 9"
            bind "Alt 1" { GoToTab 1; }
            bind "Alt 2" { GoToTab 2; }
            bind "Alt 3" { GoToTab 3; }
            bind "Alt 4" { GoToTab 4; }
            bind "Alt 5" { GoToTab 5; }
            bind "Alt 6" { GoToTab 6; }
            bind "Alt 7" { GoToTab 7; }
            bind "Alt 8" { GoToTab 8; }
            bind "Alt 9" { GoToTab 9; }
        }
    }
  '';
in
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
        # Pane navigation in shared_except "locked" to match and replace the default
        # scope. Using "shared" creates a cross-scope collision for Alt j/k where the
        # defaults bind MoveFocus but we want MoveFocusOrTab.
        "shared_except \"locked\"" = {
          "unbind \"Alt Right\"" = { };
          "unbind \"Alt Left\"" = { };
          "unbind \"Alt Up\"" = { };
          "unbind \"Alt Down\"" = { };
          "bind \"Alt h\"" = { MoveFocusOrTab = "Left"; };
          "bind \"Alt j\"" = { MoveFocus = "Down"; };
          "bind \"Alt k\"" = { MoveFocus = "Up"; };
          "bind \"Alt l\"" = { MoveFocusOrTab = "Right"; };
        };
        shared = {
          # Remove bindings so they don't conflict with helix
          "unbind \"Alt Shift 0\"" = { };
          "unbind \"Alt Shift 1\"" = { };
          "unbind \"Alt Shift 2\"" = { };
          "unbind \"Alt Shift 3\"" = { };
          "unbind \"Alt Shift 4\"" = { };
          "unbind \"Alt Shift 5\"" = { };
          "unbind \"Alt Shift 6\"" = { };
          "unbind \"Alt Shift 7\"" = { };
          "unbind \"Alt Shift 8\"" = { };
          "unbind \"Alt Shift 9\"" = { };
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
  # Each layout embeds sharedKeybinds because --layout may not inherit config.kdl keybinds
  xdg.configFile."zellij/layouts/notes.kdl".text = ''
    ${sharedKeybinds}
    pane_frames true
    layout {
        cwd "~/CloudDocs/Notes"
        new_tab_template {
             pane size=1 borderless=true {
                 plugin location="zellij:compact-bar"
             }
             pane borderless=true
         }
        tab name="daily" {
            pane size=1 borderless=true {
                plugin location="zellij:compact-bar"
            }
            pane size=8 borderless=true name="tasks" command="fish" {
                args "-c" "ft '@weekly|@today'"
            }
            pane borderless=true name="editor" focus=true command="fish" {
                args "-c" "daily; notes-sync"
            }
        }
        tab name="notes" {
            pane size=1 borderless=true {
                plugin location="zellij:compact-bar"
            }
            pane borderless=true focus=true command="fish" {
                args "-c" "notes"
            }
        }
        tab name="tasks" {
            pane size=1 borderless=true {
                plugin location="zellij:compact-bar"
            }
            pane borderless=true name="overdue" focus=true command="fish" {
                args "-c" "overdue"
            }
            pane borderless=true name="next 3 days" command="fish" {
                args "-c" "upcoming 3"
            }
        }
        tab name="search" {
            pane size=1 borderless=true {
                plugin location="zellij:compact-bar"
            }
            pane borderless=true focus=true command="fish" {
                args "-c" "sn -n"
            }
        }
        tab name="shell" {
            pane size=1 borderless=true {
                plugin location="zellij:compact-bar"
            }
            pane borderless=true focus=true
        }
    }
  '';

  xdg.configFile."zellij/layouts/compact-top.kdl".text = ''
    ${sharedKeybinds}
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
