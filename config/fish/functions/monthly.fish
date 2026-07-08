function monthly --description="Create a monthly review note in monthly/"
    _require_notes; or return 1

    set -l month (date +%Y-%m)
    set -l formatted (date +"%B %Y")
    set -l dir "$NOTES/monthly"
    set -l filepath "$dir/$month.md"
    mkdir -p "$dir"

    if not test -e "$filepath"
        set -l id (uuidgen)
        echo "---
id: $id
aliases:
  - $formatted Review
tags: []
---

# $formatted

## Highlights

## Completed

## Challenges

## Next Month Priorities

## Notes" >"$filepath"
        echo "Created: $filepath"
    end

    set -l prev_dir $PWD
    cd $NOTES
    $EDITOR "$filepath"
    cd $prev_dir
end
