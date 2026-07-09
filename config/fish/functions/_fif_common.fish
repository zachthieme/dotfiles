function _fif_common --description="Internal helper for file searching functions"
    # An empty flag must expand to zero arguments — an empty-string argument
    # would be taken by rg as its pattern, shifting the real pattern to a path
    set -l ignore_case_flag
    if test -n "$argv[1]"
        set ignore_case_flag $argv[1]
    end
    set -l search_term $argv[2]

    if test -z "$search_term"
        echo "Usage: _fif_common <ignore_case_flag> <search_term>"
        return 1
    end

    # Quote the term for the preview shell ('\'' works in sh and fish) so
    # quotes/metacharacters in it can't break out of the preview command
    set -l quoted_term (string replace -a "'" "'\\''" -- $search_term)
    set -l preview_cmd "rg $ignore_case_flag --pretty --context 10 -- '$quoted_term' {}"

    set -l files (rg --files-with-matches $ignore_case_flag --no-messages -- "$search_term" | \
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
