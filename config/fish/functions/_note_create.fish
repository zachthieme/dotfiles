function _note_create --description="Create a note from template if missing; prints its path. Usage: _note_create <type> <name>"
    set -l type $argv[1]
    set -l name (_titlecase $argv[2..])

    set -l dir
    switch $type
        case person
            set dir people
        case project
            set dir projects
        case company
            set dir companies
        case adr decision
            set dir decisions
        case incident
            set dir incidents
        case '*'
            echo "Unknown note type: $type" >&2
            return 1
    end

    set -l filepath "$NOTES/$dir/$name.md"
    mkdir -p "$NOTES/$dir"

    if not test -e "$filepath"
        _note_template $type $name >"$filepath"
        echo "Created: $filepath" >&2
    end

    echo -n "$filepath"
end
