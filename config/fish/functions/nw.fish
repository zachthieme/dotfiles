function nw --description="Open notes workspace in tmux, commit and push on close"
    _require_notes_dir; or return 1

    if set -q TMUX
        echo "Already inside a tmux session"
        return 1
    end

    set -l notes_dir $NOTES
    set -l session notes

    # Attach if session already exists
    if tmux has-session -t $session 2>/dev/null
        tmux attach-session -t $session
        notes-sync
        return
    end

    # Tab 1: daily — split row-major so pane indexes follow reading order
    # (1=pike top-left, 2=wen top-right, 3=editor bot-left, 4=tick bot-right, 5=sync)
    #   pike (1)    | wen (2)   28 wide, 10 tall
    #   ------------+---------
    #   editor (3)  | tick (4)   14 tall
    #               | sync (5)
    # Create session at current terminal size so pane layout survives attach
    set -l cols (tput cols)
    set -l rows (tput lines)
    set -l pike_pane (tmux new-session -d -s $session -n daily -c $notes_dir -x $cols -y $rows -P -F '#{pane_id}')
    # Row split: top (pike) over bottom (editor)
    set -l editor_pane (tmux split-window -v -t $pike_pane -c $notes_dir -P -F '#{pane_id}')
    tmux resize-pane -t $pike_pane -y 10
    # Top row: pike | wen
    set -l wen_pane (tmux split-window -h -l 28 -t $pike_pane -c $notes_dir -P -F '#{pane_id}')
    # Bottom row: editor | tick (right column becomes tick+sync)
    set -l tick_pane (tmux split-window -h -l 28 -t $editor_pane -c $notes_dir -P -F '#{pane_id}')
    tmux split-window -v -t $tick_pane -c $notes_dir "fish -c 'while true; notes-sync >/dev/null 2>&1; and echo synced (date +%H:%M); or echo sync FAILED (date +%H:%M); sleep 3600; end'"
    tmux resize-pane -t $tick_pane -y 12

    # Pin right column to 28 wide on terminal resize
    tmux set-hook -t $session window-resized "resize-pane -t $pike_pane -y 10 ; resize-pane -t $wen_pane -x 28 ; resize-pane -t $tick_pane -x 28 ; resize-pane -t $tick_pane -y 12"

    tmux send-keys -t $pike_pane "pike -w priority" Enter
    tmux send-keys -t $wen_pane "wen cal" Enter
    tmux send-keys -t $editor_pane "daily; notes-sync" Enter
    tmux send-keys -t $tick_pane "tick --hosts $NW_TICK_HOSTS --deadline $NW_TICK_DEADLINE" Enter

    tmux select-pane -t $editor_pane

    # Tab 2: tasks — pike
    tmux new-window -t $session -n tasks -c $notes_dir
    tmux send-keys pike Enter

    # Tab 3: herdr — AI agent workspace
    tmux new-window -t $session -n herdr -c $notes_dir
    tmux send-keys herdr Enter

    # Tab 4: shell
    tmux new-window -t $session -n shell -c $notes_dir

    # Start on the daily tab
    tmux select-window -t $session:1

    tmux attach-session -t $session

    # Final sync after tmux exits
    notes-sync
end
