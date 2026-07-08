function _daily_create --description="Create today's daily note from template if missing; prints its path"
    if not set -q NOTES; or test -z "$NOTES"
        echo "NOTES not set" >&2
        return 1
    end

    set -l today (date +%Y-%m-%d)
    set -l formatted (date +"%A %B %-d, %Y")
    set -l dir "$NOTES/daily"
    set -l filepath "$dir/$today.md"
    mkdir -p "$dir"

    if not test -e "$filepath"
        set -l id (uuidgen)
        printf "%s\n" --- "id: $id" "aliases:" "  - $formatted" "tags: []" --- "" "# $formatted" "" "## Meetings" "" "## Notes" >"$filepath"
        echo "Created: $filepath" >&2
    end

    echo -n "$filepath"
end
