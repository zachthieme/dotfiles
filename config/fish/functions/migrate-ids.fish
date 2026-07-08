function migrate-ids --description="Replace non-GUID ids in note frontmatter with UUIDs"
    _require_notes; or return 1

    set -l uuid_pattern '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    set -l count 0

    for file in (fd --type f --extension md . "$NOTES")
        # extract id value from frontmatter (between first two --- markers)
        set -l id_value (awk '/^---$/{n++; next} n==1 && /^id:/{sub(/^id: */, ""); print; exit}' "$file")
        if test -z "$id_value"
            continue
        end

        # skip if already a UUID
        if string match -rq $uuid_pattern "$id_value"
            continue
        end

        set -l new_id (uuidgen)
        awk -v new_id="$new_id" '/^id:/ && !done {print "id: " new_id; done=1; next} {print}' "$file" >"$file.tmp" && mv "$file.tmp" "$file"
        echo "  $file: $id_value → $new_id"
        set count (math $count + 1)
    end

    if test $count -eq 0
        echo "All notes already have GUID ids."
    else
        echo "Updated $count note(s)."
    end
end
