# Fish functions for task checkbox management
# Task querying, filtering, and dashboards are handled by pike
{ ... }:

{
  programs.fish.functions = {
    _hx_toggle_task = {
      description = "Toggle task checkbox with @completed date (used by helix :pipe)";
      body = ''
        set -l d (date +%Y-%m-%d)
        while read -l line
          if string match -qr '^\s*- \[ \] ' -- "$line"
            set -l toggled (string replace -- '- [ ] ' '- [x] ' "$line")
            set -l cleaned (string replace -r ' *@completed\(\d{4}-\d{2}-\d{2}\)' ''' -- "$toggled")
            echo "$cleaned @completed($d)"
          else if string match -qr '^\s*- \[[xX]\] ' -- "$line"
            set -l toggled (string replace -r -- '- \[[xX]\] ' '- [ ] ' "$line")
            set -l cleaned (string replace -r ' *@completed\(\d{4}-\d{2}-\d{2}\)' ''' -- "$toggled")
            echo "$cleaned"
          else
            echo "$line"
          end
        end
      '';
    };
  };
}
