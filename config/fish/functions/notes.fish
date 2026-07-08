function notes --description="Search notes or create new note"
    _require_notes_dir; or return 1

    set -l prev_dir $PWD
    cd $NOTES

    set -l selected (fd --type f --extension md . "$NOTES" | \
  fzf --print-query \
      --preview "bat --force-colorization --style=plain --line-range :50 {}" \
      --preview-window=right:50%:wrap:border-left \
      --height=100% \
      --layout=reverse \
      --border none --no-separator --no-info \
      --bind "ctrl-n:print-query+abort")

    set -l search_query $selected[1]
    set -l chosen_file $selected[2]

    # If file was selected, open it
    if test -n "$chosen_file" -a -e "$chosen_file"
        $EDITOR "$chosen_file"
        cd $prev_dir
        return 0
    end

    # If we have a query (from typing or ctrl-n), create new note
    if test -n "$search_query"
        set -l filename (_slugify "$search_query")".md"
        set -l filepath "$NOTES/$filename"

        if test -e "$filepath"
            echo "File already exists: $filepath"
            $EDITOR "$filepath"
        else
            echo "# $search_query" >"$filepath"
            echo "Created: $filepath"
            $EDITOR "$filepath"
        end
    end
    cd $prev_dir
end
