function _hx_ensure_note --description="Create a note from template if it doesn't exist; echoes the selection back unchanged (used by helix :pipe)"
    set -l type $argv[1]
    # `read -z` slurps all of stdin into one string, preserving embedded
    # newlines. The earlier `set input (cat)` split stdin on newlines (mangling
    # multi-line selections into space-joined text) and, being a command
    # substitution, could only read fish's own pipe — never a redirected stdin —
    # which made this function impossible to exercise in notes-test.
    read -lz input
    set -l match (string match -r '\[\[([^\]]+)\]\]' -- $input)
    set -l name
    if test -n "$match[2]"
        set name $match[2]
    else
        set name (string trim -- $input)
    end

    if test -z "$name"; or not set -q NOTES; or test -z "$NOTES"
        printf '%s' $input
        return 1
    end

    set -l filepath (_note_create $type $name 2>/dev/null)
    if test -z "$filepath"
        printf '%s' $input
        return 1
    end

    printf '%s' $input
end
