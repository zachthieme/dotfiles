# Tmux terminal multiplexer configuration
# Navigation mirrors zellij: Alt+h/j/k/l for panes, Alt+1-9 for windows
{ pkgs, ... }:

{
  catppuccin.tmux = {
    enable = true;
    extraConfig = ''
      set -g @catppuccin_window_status_style "rounded"
      set -g @catppuccin_window_text "#W"
      set -g @catppuccin_window_current_text "#W"
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_session}#{E:@catppuccin_status_date_time}"
    '';
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";
    prefix = "M-Space";

    extraConfig = ''
      # True color support
      set -as terminal-features ",xterm-256color:RGB"
      set -as terminal-features ",ghostty:RGB"

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Pane borders — active matches JankyBorders green
      set -g pane-border-style "fg=#1e1e2e"
      set -g pane-active-border-style "fg=#a6e3a1"

      # Pane splitting — leader+| for side-by-side, leader+- for stacked
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Pane navigation — Alt+h/j/k/l (no prefix needed, matches zellij)
      # Wraps to previous/next window at pane boundaries
      bind -n M-h if -F '#{pane_at_left}'   'previous-window' 'select-pane -L'
      bind -n M-j if -F '#{pane_at_bottom}' '''               'select-pane -D'
      bind -n M-k if -F '#{pane_at_top}'    '''               'select-pane -U'
      bind -n M-l if -F '#{pane_at_right}'  'next-window'     'select-pane -R'

      # Window (tab) switching — Alt+1-9 (no prefix needed, matches zellij)
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Pane resizing with prefix+arrow keys
      bind -r Left resize-pane -L 5
      bind -r Down resize-pane -D 5
      bind -r Up resize-pane -U 5
      bind -r Right resize-pane -R 5

      # New window in current path
      bind c new-window -c "#{pane_current_path}"

      # Vi copy mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Status bar at top (matches zellij compact-top layout)
      set -g status-position top
    '';

};
}
