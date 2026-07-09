function weekly --description="Create a weekly review note in reviews/"
    _require_notes; or return 1

    set -l today (date +%Y-%m-%d)
    set -l formatted (date +"%B %-d, %Y")
    set -l dir "$NOTES/reviews"
    set -l filepath "$dir/$today.md"
    mkdir -p "$dir"

    if not test -e "$filepath"
        set -l id (uuidgen)
        echo "---
id: $id
aliases:
  - Week of $formatted
tags: []
---

# Week of $formatted

## Wins

## Challenges

## Next Week Priorities

## Notes" >"$filepath"
        echo "Created: $filepath"
    end

    set -l prev_dir $PWD
    cd $NOTES
    or return 1
    $EDITOR "$filepath"
    cd $prev_dir
end
