function sn --description="Search inside notes by content"
    argparse n/no-preview -- $argv; or return 1
    _require_notes_dir; or return 1

    set -l prev_dir $PWD
    cd $NOTES
    or return 1

    set -l fzf_opts --ansi --delimiter : --height=100% --layout=reverse --border none --no-separator --no-info
    if not set -q _flag_no_preview
        set -a fzf_opts --preview "bat --force-colorization --highlight-line {2} {1}" --preview-window=right:50%:wrap
    end

    set -l query (string join " " -- $argv)
    set -l selection (rg --color=always --line-number --no-heading --smart-case -- "$query" "$NOTES" | \
  fzf $fzf_opts)

    if test -n "$selection"
        set -l file (echo "$selection" | string split -f1 :)
        set -l line (echo "$selection" | string split -f2 :)
        $EDITOR "+$line" "$file"
    end
    cd $prev_dir
end
