function _hx_ensure_note --description="Create a note from template if missing, write path to /tmp/hx_note_path (used by helix :pipe)"
    set -l type $argv[1]
    set -l input (cat)
    # Handle both [[Name]] (with brackets) and bare Name (selected inside brackets)
    set -l match (string match -r '\[\[([^\]]+)\]\]' -- $input)
    set -l name
    if test -n "$match[2]"
        set name $match[2]
    else
        set name (string trim -- $input)
    end

    if test -z "$name"; or not set -q NOTES; or test -z "$NOTES"
        echo -n $input
        return 1
    end

    set -l filepath (_note_create $type $name 2>/dev/null)
    if test -z "$filepath"
        echo -n $input
        return 1
    end

    echo -n "$filepath" >/tmp/hx_note_path
    echo -n $input
end
