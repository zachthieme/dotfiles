function notes-sync-loop --description="Run notes-sync hourly; show only the last 5 results, newest first"
    # Runs in the `nw` sync pane. The pane is short, so instead of appending a
    # line per run forever (which pushes the newest result below the fold after
    # a few days), keep a rolling buffer of the last N results, newest on top,
    # and repaint each cycle.
    set -l keep 5
    set -l lines
    while true
        set -l stamp (date "+%Y-%m-%d %H:%M")
        set -l entry
        if notes-sync >/dev/null 2>&1
            set entry (set_color green)"$stamp"(set_color normal)
        else
            set entry (set_color red)"$stamp"(set_color normal)
        end
        # Prepend the newest; keep only the most recent $keep entries.
        set lines $entry $lines
        if test (count $lines) -gt $keep
            set lines $lines[1..$keep]
        end
        clear
        printf '%s\n' $lines
        sleep 3600
    end
end
