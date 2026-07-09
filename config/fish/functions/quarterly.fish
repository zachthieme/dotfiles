function quarterly --description="Create a quarterly review note in quarterly/. Usage: quarterly Q4 [year]"
    if test (count $argv) -eq 0
        echo "Usage: quarterly <quarter> [year]"
        echo "Example: quarterly Q4 2024"
        return 1
    end
    _require_notes; or return 1

    set -l quarter $argv[1]
    set -l year (date +%Y)
    if test (count $argv) -gt 1
        set year $argv[2]
    end

    set -l dir "$NOTES/quarterly"
    set -l filepath "$dir/$year-$quarter.md"
    mkdir -p "$dir"

    if not test -e "$filepath"
        set -l id (uuidgen)
        echo "---
id: $id
aliases:
  - $quarter $year Review
tags: []
---

# $quarter $year Review

## Goals

## Accomplishments

## What Worked

## What Didn't

## Key Learnings

## Next Quarter Priorities" >"$filepath"
        echo "Created: $filepath"
    end

    set -l prev_dir $PWD
    cd $NOTES
    or return 1
    $EDITOR "$filepath"
    cd $prev_dir
end
