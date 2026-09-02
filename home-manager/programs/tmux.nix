# Tmux terminal multiplexer configuration
# Prefix: Alt+Space on macOS, Ctrl+b everywhere else (see `prefix` below)
# Navigation: Alt+h/j/k/l for panes, Alt+1-9 for windows
{
  config,
  lib,
  pkgs,
  ...
}: let
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
  # Idempotently merges tmux-tab-pulse's hook entries into Claude Code's user
  # settings. Keyed on (event, matcher, command), so removing one by hand
  # restores just that one, and herdr's own SessionStart hook is left alone —
  # Claude Code merges hook entries across settings levels rather than
  # replacing them.
  hooksJq = pkgs.writeText "tab-pulse-claude-hooks.jq" ''
    def ensure($event; $matcher; $cmd):
      (.hooks //= {})
      | (.hooks[$event] //= [])
      | if any(.hooks[$event][];
               (if $matcher == null
                then (.matcher // null) == null
                else (.matcher // null) == $matcher
                end)
               and any(.hooks[]?; (.command // null) == $cmd))
        then .
        else .hooks[$event] += [
          (if $matcher == null
           then {hooks: [{type: "command", command: $cmd}]}
           else {matcher: $matcher, hooks: [{type: "command", command: $cmd}]}
           end)
        ]
        end;
    ensure("SessionStart"; null; $p + " idle")
    | ensure("UserPromptSubmit"; null; $p + " working")
    | ensure("Stop"; null; $p + " idle")
    | ensure("Notification"; "agent_needs_input"; $p + " attention")
    | ensure("Notification"; "permission_prompt"; $p + " attention")
    | ensure("SessionEnd"; null; $p + " clear")
  '';
  # Every host binds the Alt keys below with no prefix, which is what breaks
  # when tmux nests: the macOS server holding an ssh pane grabs the keystroke
  # and the tmux on the far end never sees it. The prefix split above doesn't
  # help here — these have no prefix to disambiguate.
  #
  # So on the outer (macOS) server, forward the key instead whenever the pane
  # is running ssh/mosh *and* has switched to the alternate screen. That pair
  # is the closest an outer tmux can get to "there is a full-screen program
  # over there": a remote tmux always trips both, a bare remote shell trips
  # neither, and a local helix or pager trips only the second. So remote panes
  # forward and everything else keeps local navigation, decided per keystroke
  # rather than by a mode you have to remember you're in.
  remotePane = "#{&&:#{m/r:^(ssh|mosh)$,#{pane_current_command}},#{alternate_on}}";
  # Linux hosts are always the inner tmux, so they bind these unconditionally.
  altBind = key: action:
    if pkgs.stdenv.isDarwin
    then "bind -n ${key} if -F '${remotePane}' 'send-keys ${key}' { ${action} }"
    else "bind -n ${key} ${action}";
  altBinds = binds: lib.concatStringsSep "\n" (lib.mapAttrsToList altBind binds);

  paneNavBinds = altBinds {
    "M-h" = "if -F '#{pane_at_left}'   'previous-window' 'select-pane -L'";
    "M-j" = "if -F '#{pane_at_bottom}' ''               'select-pane -D'";
    "M-k" = "if -F '#{pane_at_top}'    ''               'select-pane -U'";
    "M-l" = "if -F '#{pane_at_right}'  'next-window'     'select-pane -R'";
  };
  windowBinds = altBinds (lib.listToAttrs (map (n: {
    name = "M-${toString n}";
    value = "select-window -t ${toString n}";
  }) (lib.range 1 9)));
  paneTableBind = altBinds {"M-p" = "switch-client -T panes";};
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
      set -g @catppuccin_window_text "#W #{?@tab_pulse,#{@tab_pulse}, }#[fg=#{@thm_fg},bg=#{E:@catppuccin_window_text_color}]"
      set -g @catppuccin_window_current_text "#W #{?@tab_pulse,#{@tab_pulse}, }#[fg=#{@thm_fg},bg=#{E:@catppuccin_window_current_text_color}]"
      set -g status-left "#{E:@catppuccin_status_session}"
      set -g @catppuccin_date_time_text "%H:%M"
      set -g status-right "#{E:@catppuccin_status_date_time}"
    '';
  };

  # tmux-tab-pulse only shows Claude's working/blocked states if Claude Code
  # fires its hooks. settings.json can't be a home.file symlink (Claude Code
  # writes to it), so merge the entries in on every switch instead — that way a
  # new machine needs no manual step.
  home.activation.tabPulseClaudeHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settings="${config.home.homeDirectory}/.claude/settings.json"
    # $HOME, not the store path: the symlink below survives plugin bumps, and
    # the same entry works on macOS (/Users) and Linux (/home).
    state='bash "$HOME/.local/share/tmux-tab-pulse/scripts/claude-state.sh"'

    if [ -e "$settings" ] && ! ${pkgs.jq}/bin/jq -e . "$settings" >/dev/null 2>&1; then
      warnEcho "tmux-tab-pulse: $settings is not valid JSON, leaving Claude Code hooks alone"
    else
      existing='{}'
      if [ -e "$settings" ]; then
        existing="$(cat "$settings")"
      fi
      updated="$(printf '%s' "$existing" | ${pkgs.jq}/bin/jq --arg p "$state" -f ${hooksJq} || true)"

      # Never write what jq didn't successfully produce — an empty or partial
      # result here would truncate a live settings file.
      if ! printf '%s' "$updated" | ${pkgs.jq}/bin/jq -e 'type == "object" and has("hooks")' >/dev/null 2>&1; then
        warnEcho "tmux-tab-pulse: could not merge Claude Code hooks, leaving $settings alone"
      else
        before="$(printf '%s' "$existing" | ${pkgs.jq}/bin/jq -S .)"
        after="$(printf '%s' "$updated" | ${pkgs.jq}/bin/jq -S .)"
        if [ "$before" != "$after" ]; then
          tmp="$(mktemp)"
          printf '%s\n' "$updated" >"$tmp"
          run mkdir -p "${config.home.homeDirectory}/.claude"
          run cp "$tmp" "$settings"
          rm -f "$tmp"
          noteEcho "tmux-tab-pulse: merged Claude Code hooks into $settings"
        fi
      fi
    fi
  '';

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
    # Prefix differs by platform so nesting works: the Mac laptops are always
    # the outer tmux (or no tmux at all), the Linux boxes are always the inner
    # one reached over ssh. Alt+Space never collides with the C-b that the
    # remote session is listening for, so an inner keystroke is never eaten by
    # the outer server. Ghostty sets macos-option-as-alt, which turns Option
    # into the ESC prefix that makes M-Space reach tmux at all.
    prefix =
      if pkgs.stdenv.isDarwin
      then "M-Space"
      else "C-b";

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
      ${paneNavBinds}

      # Window (tab) switching — Alt+1-9 (no prefix needed)
      ${windowBinds}

      # Pane switching — Alt+P enters "panes" key table, then 1-9 selects pane
      # Tmux owns the second keystroke so apps (helix) never see it
      ${paneTableBind}
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
