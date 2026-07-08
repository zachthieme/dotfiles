function daily --description="Create or open today's daily note in daily/"
    _require_notes; or return 1

    set -l filepath (_daily_create)
    or return 1

    set -l prev_dir $PWD
    cd $NOTES
    $EDITOR "$filepath"
    cd $prev_dir
end
