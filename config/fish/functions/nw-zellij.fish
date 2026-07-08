function nw-zellij --description="Open notes workspace in zellij, commit and push on close"
    _require_notes_dir; or return 1

    if set -q ZELLIJ
        echo "Already inside a zellij session"
        return 1
    end

    zellij --layout ~/.config/zellij/layouts/notes.kdl attach --create notes

    # Final sync after zellij exits (catches anything panes missed)
    notes-sync
end
