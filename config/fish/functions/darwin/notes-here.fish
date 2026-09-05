function notes-here --description="Bring the notes (nw) ghostty window to the current workspace"
    # Every ghostty window shares one bundle id, so match on the title pure's
    # fish_title sets just before `nw` execs: "<dir>: <last cmd> - <cur cmd>".
    # tmux leaves the title alone (set-titles is off), so it survives the
    # whole session.
    aero-summon com.mitchellh.ghostty '*: nw - nw'
end
