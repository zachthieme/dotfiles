function _note_edit --description="Create a note if missing and open it in EDITOR. Usage: _note_edit <type> <name>"
    set -l type $argv[1]
    set -l name $argv[2..]
    if test -z "$name"
        echo "Usage: $type <name>"
        return 1
    end
    _require_notes; or return 1

    set -l filepath (_note_create $type $name)
    or return 1

    set -l prev_dir $PWD
    cd $NOTES
    $EDITOR "$filepath"
    cd $prev_dir
end
