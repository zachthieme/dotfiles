function nwk --description="Kill the notes tmux session"
    tmux kill-session -t notes 2>/dev/null
    and echo "Killed notes session."
    or echo "No notes session running."
end
