function _fif_common --description="Internal helper for file searching functions"
    set -l ignore_case_flag $argv[1]
    set -l search_term $argv[2]

    if test -z "$search_term"
        echo "Usage: _fif_common <ignore_case_flag> <search_term>"
        return 1
    end

    set -l preview_cmd "rg $ignore_case_flag --pretty --context 10 '$search_term' {}"

    set -l files (rg --files-with-matches $ignore_case_flag --no-messages "$search_term" | \
  fzf-tmux +m --preview="$preview_cmd" --multi --select-1 --exit-0)

    if test (count $files) -eq 0
        echo "No files selected."
        return 0
    end

    set -l resolved_files
    for file in $files
        set -a resolved_files (realpath "$file")
    end

    $EDITOR $resolved_files
end
