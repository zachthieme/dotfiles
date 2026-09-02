# Tmux terminal multiplexer configuration
# Navigation: Alt+h/j/k/l for panes, Alt+1-9 for windows
{pkgs, ...}: let
  # Busy/idle marker in each window tab: spinner while Claude Code works,
  # red ⚠ when it's blocked on you, ● for any other running process.
  # Not in nixpkgs — pinned by commit.
  tab-pulse = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tab-pulse";
    # Default rtpFilePath would be tab_pulse.tmux (mkTmuxPlugin swaps - for _)
    # and mkTmuxPlugin does not check that the file exists.
    rtpFilePath = "tab-pulse.tmux";
    version = "0-unstable-2026-07-23";
    src = pkgs.fetchFromGitHub {
      owner = "rafaelsales";
      repo = "tmux-tab-pulse";
      rev = "8fce73606752d520a9869bb146201f1067316352";
      hash = "sha256-vhQWu4uck7evlzvhgRNMkj7RRFazkgjKUgfn9DZ7nm8=";
    };
    # Scripts keep their `#!/usr/bin/env bash` shebangs: patchShebangs can't
    # rewrite them (cp from the store leaves $target read-only), and the
    # daemon shells out to awk/sed/grep unqualified anyway — bash and awk are
    # ambient requirements either way.
    meta.homepage = "https://github.com/rafaelsales/tmux-tab-pulse";
  };
in {
  catppuccin.tmux = {
    enable = true;
    extraConfig = ''
      set -g @catppuccin_window_status_style "rounded"
      # Reserve one cell for tmux-tab-pulse's busy/idle glyph inside the tab
      # chip. The glyph ends in a hardcoded #[default], which drops the chip's
      # background, so restore catppuccin's own text style right after it.
      # E: on the colour options because their values are themselves format
      # references (#{@thm_surface_0}) and need the second expansion pass.
      # The style sits outside the #{?...} — tmux splits conditional branches
      # on commas, so a #[fg=...,bg=...] inside one tears the format in half.
      set -g @catppuccin_window_text "#W#{?@tab_pulse,#{@tab_pulse}, }#[fg=#{@thm_fg},bg=#{E:@catppuccin_window_text_color}]"
      set -g @catppuccin_window_current_text "#W#{?@tab_pulse,#{@tab_pulse}, }#[fg=#{@thm_fg},bg=#{E:@catppuccin_window_current_text_color}]"
      set -g status-left "#{E:@catppuccin_status_session}"
      set -g @catppuccin_date_time_text "%H:%M"
      set -g status-right "#{E:@catppuccin_status_date_time}"
    '';
  };

  # Stable path for Claude Code's hooks to call — ~/.claude/settings.json is
  # not managed here, so it must not reference a store path that changes on
  # every plugin bump.
  home.file.".local/share/tmux-tab-pulse".source = "${tab-pulse}/share/tmux-plugins/tab-pulse";

  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";
    prefix = "C-b";

    plugins = [
      {
        plugin = tab-pulse;
        # Manual mode: catppuccin rewrites window-status-format when it loads,
        # so let it own the format and carry #{@tab_pulse} inside
        # @catppuccin_window_text instead (see catppuccin.tmux above).
        # Both options are read once, at plugin load — they must be set before
        # the run-shell that follows this block.
        extraConfig = ''
          set -g @tab-pulse-manual on
          set -g @tab-pulse-ignore-commands "hx nvim vim vi less more man htop btop top fzf tig lazygit bat delta"
        '';
      }
    ];

    extraConfig = ''
      # True color support
      set -as terminal-features ",xterm-256color:RGB"
      set -as terminal-features ",ghostty:RGB"

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Pane numbering starts at 1 (matches baseIndex for windows)
      set -g pane-base-index 1
      setw -g pane-base-index 1

      # Pane borders — inactive matches the pane background so they disappear;
      # the active pane gets a subtle catppuccin-green frame to mark focus.
      set -g pane-border-style "fg=#181825"
      set -g pane-active-border-style "fg=#a6e3a1"

      # Dim inactive panes via background (catppuccin mocha: mantle inactive, base active)
      set -g window-style 'bg=#181825'
      set -g window-active-style 'bg=#1e1e2e'

      # Pane splitting — leader+| for side-by-side, leader+- for stacked
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Pane navigation — Alt+h/j/k/l (no prefix needed)
      # Wraps to previous/next window at pane boundaries
      bind -n M-h if -F '#{pane_at_left}'   'previous-window' 'select-pane -L'
      bind -n M-j if -F '#{pane_at_bottom}' '''               'select-pane -D'
      bind -n M-k if -F '#{pane_at_top}'    '''               'select-pane -U'
      bind -n M-l if -F '#{pane_at_right}'  'next-window'     'select-pane -R'

      # Window (tab) switching — Alt+1-9 (no prefix needed)
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Pane switching — Alt+P enters "panes" key table, then 1-9 selects pane
      # Tmux owns the second keystroke so apps (helix) never see it
      bind -n M-p switch-client -T panes
      bind -T panes 1 select-pane -t :.1
      bind -T panes 2 select-pane -t :.2
      bind -T panes 3 select-pane -t :.3
      bind -T panes 4 select-pane -t :.4
      bind -T panes 5 select-pane -t :.5
      bind -T panes 6 select-pane -t :.6
      bind -T panes 7 select-pane -t :.7
      bind -T panes 8 select-pane -t :.8
      bind -T panes 9 select-pane -t :.9
      bind -T panes Escape switch-client -T root

      # Pane resizing with prefix+arrow keys
      bind -r Left resize-pane -L 5
      bind -r Down resize-pane -D 5
      bind -r Up resize-pane -U 5
      bind -r Right resize-pane -R 5

      # New window in current path
      bind c new-window -c "#{pane_current_path}"

      # Window (tab) rename/close — mirrors herdr's prefix+T / prefix+X
      bind T command-prompt -I "#W" "rename-window -- '%%'"
      bind X confirm-before -p "kill-window #W? (y/n)" kill-window

      # Clipboard — OSC 52 lets tmux set the terminal clipboard directly
      # Works on macOS + Linux without platform-specific tools (Ghostty, iTerm2, etc.)
      set -g set-clipboard on

      # Vi copy mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Status bar at top
      set -g status-position top
      set -g status-justify centre
    '';
  };
}
