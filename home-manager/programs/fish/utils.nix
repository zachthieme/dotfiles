# Fish functions for general utilities — git, file search, system tools
{ ... }:

{
  programs.fish.functions = {
    aliases = {
      description = "Show all custom abbreviations and functions";
      body = ''
        echo ""
        set_color --bold cyan
        echo "═══ Abbreviations ═══"
        set_color normal
        echo ""
        printf "  %-8s %s\n" "j"    "Open jrnl"
        printf "  %-8s %s\n" "jl"   "List jrnl entries (short format)"
        printf "  %-8s %s\n" "jf"   "Open jrnl with @fire tag"
        printf "  %-8s %s\n" "n"    "Search/create notes (→ notes)"
        printf "  %-8s %s\n" "fw"   "Priority tasks (→ pike -w Priority)"
        printf "  %-8s %s\n" "fo"   "Overdue tasks (→ pike -w Overdue)"
        printf "  %-8s %s\n" "fu"   "Upcoming tasks (→ pike -w 'Next 3 Days')"
        printf "  %-8s %s\n" "td"   "Task summary (→ pike --summary)"
        printf "  %-8s %s\n" "vi"   "Open helix editor"
        printf "  %-8s %s\n" "ls"   "List files with eza"
        printf "  %-8s %s\n" "ll"   "List files (long format with git)"
        printf "  %-8s %s\n" "lt"   "List files as tree (2 levels)"
        echo ""
        set_color --bold cyan
        echo "═══ Note Templates ═══"
        set_color normal
        echo ""
        printf "  %-12s %s\n" "daily"     "Create/open today's daily note (daily/)"
        printf "  %-12s %s\n" "weekly"    "Create/open weekly review (weekly/)"
        printf "  %-12s %s\n" "quarterly" "Create quarterly review (quarterly/)"
        printf "  %-12s %s\n" "monthly"   "Create monthly review (monthly/)"
        printf "  %-12s %s\n" "person"    "Create person profile (people/)"
        printf "  %-12s %s\n" "project"   "Create project note (projects/)"
        printf "  %-12s %s\n" "company"   "Create company research (companies/)"
        printf "  %-12s %s\n" "adr"       "Create architecture decision record (adrs/)"
        printf "  %-12s %s\n" "decision"  "Create decision document (decisions/)"
        printf "  %-12s %s\n" "incident"  "Create incident report (incidents/)"
        echo ""
        set_color --bold cyan
        echo "═══ Search & Tasks ═══"
        set_color normal
        echo ""
        printf "  %-12s %s\n" "notes"      "Search notes or create new note (alias: n)"
        printf "  %-12s %s\n" "sn"         "Search inside notes by content (sn [-n])"
        printf "  %-12s %s\n" "pike"       "Task dashboard (pike -h for all options)"
        printf "  %-12s %s\n" "review"     "Create review with completed tasks (review [week|month])"
        printf "  %-12s %s\n" "nw"         "Open notes workspace (syncs on close)"
        printf "  %-12s %s\n" "notes-sync" "Commit and push notes via jj"
        echo ""
        set_color --bold cyan
        echo "═══ File Search ═══"
        set_color normal
        echo ""
        printf "  %-12s %s\n" "fif"       "Case-insensitive search in files"
        printf "  %-12s %s\n" "fifs"      "Case-sensitive search in files"
        printf "  %-12s %s\n" "fifc"      "Search in chezmoi-managed files"
        echo ""
        set_color --bold cyan
        echo "═══ Git & System ═══"
        set_color normal
        echo ""
        printf "  %-12s %s\n" "gff"       "Interactive git file history explorer"
        printf "  %-12s %s\n" "logg"      "Interactive git log explorer"
        printf "  %-12s %s\n" "k"         "Interactive process killer"
        printf "  %-12s %s\n" "mkdd"      "Create directory with today's date"
        printf "  %-12s %s\n" "nix-cleanup" "Clean up Nix store"
        printf "  %-12s %s\n" "migrate-ids" "Replace non-UUID note ids with UUIDs"
        echo ""
      '';
    };

    gff = {
      description = "Interactive Git file history explorer";
      body = ''
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
      '';
    };

    k = {
      description = "Interactive process killer using fzf";
      body = ''
        ps aux | \
        fzf --height 40% \
            --layout=reverse \
            --header-lines=1 \
            --prompt="Select process to kill: " \
            --preview 'echo {}' \
            --preview-window up:3:hidden:wrap \
            --bind 'F2:toggle-preview' | \
        awk '{print $2}' | \
        xargs -r bash -c 'if ! kill "$1" 2>/dev/null; then echo "Regular kill failed. Attempting with sudo..."; sudo kill "$1" || echo "Failed to kill process $1" >&2; fi' --
      '';
    };

    logg = {
      description = "Interactive Git log explorer with previews";
      body = ''
        if not git rev-parse --git-dir &>/dev/null
          echo -e "\033[31mError:\033[0m Not a git repository"
          return 1
        end

        git log | fzf --ansi --no-sort \
          --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show % --color=always' \
          --preview-window=right:50%:wrap --height 100% \
          --bind 'enter:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "git show % | $EDITOR -")' \
          --bind 'ctrl-e:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "gh browse %")'
      '';
    };

    mkdd = {
      description = "Create a directory with today's date";
      body = ''
        set -l prefix ""
        if test (count $argv) -gt 0
          set prefix "$argv[1]"
        end
        mkdir -p "$prefix"(date +%F)
      '';
    };

    _fif_common = {
      description = "Internal helper for file searching functions";
      body = ''
        set -l ignore_case_flag $argv[1]
        set -l search_term $argv[2]
        set -l chezmoi_flag ""
        if test (count $argv) -ge 3
          set chezmoi_flag $argv[3]
        end

        if test -z "$search_term"
          echo "Usage: _fif_common <ignore_case_flag> <search_term> [--chezmoi]"
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

        if test "$chezmoi_flag" = "--chezmoi"
          cm edit $resolved_files
        else
          $EDITOR $resolved_files
        end
      '';
    };

    fifs = {
      description = "Case-sensitive search for text in files";
      body = ''
        _fif_common "" $argv
      '';
    };

    fifc = {
      description = "Case-sensitive search in chezmoi-managed files";
      body = ''
        _fif_common "" $argv "--chezmoi"
      '';
    };

    fif = {
      description = "Case-insensitive search for text in files";
      body = ''
        _fif_common "--ignore-case" $argv
      '';
    };

    nix-cleanup = {
      description = "Clean up the Nix store by removing unused packages";
      body = ''
        echo "Collecting garbage from the Nix store..."
        sudo nix-collect-garbage -d
        echo "Garbage collection complete!"
      '';
    };
  };
}
