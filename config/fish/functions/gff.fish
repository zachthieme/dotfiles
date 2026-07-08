function gff --description="Interactive Git file history explorer"
    if test -z "$argv[1]"
        echo -e "\033[31mError:\033[0m Please provide a file path."
        echo "Usage: gff <file>"
        return 1
    end

    set -l file $argv[1]
    set -l repo_root (git rev-parse --show-toplevel)
    set -l rel_file (string replace "$repo_root/" "" "$file")

    echo -e "\033[34mSearching Git history for:\033[0m $rel_file"

    set -l selected_commit (git log --oneline --follow -- "$rel_file" | \
  fzf --preview "git show {1}:$rel_file --color=always" \
      --preview-window=right:70%:wrap --height=80% --border --ansi)

    if test -z "$selected_commit"
        echo -e "\033[33mNo commit selected.\033[0m"
        return 0
    end

    set -l commit_hash (echo "$selected_commit" | awk '{print $1}')
    echo -e "\033[34mSelected Commit:\033[0m $commit_hash"
    echo -e "\033[34mFile Content Previewed Above.\033[0m"
end
