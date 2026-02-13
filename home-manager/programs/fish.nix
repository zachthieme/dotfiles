# Fish shell configuration
{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # Disable greeting
      set -g fish_greeting

      # Add Home Manager and Nix paths early (Linux only - must happen before interactiveShellInit)
      ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
        fish_add_path --prepend ~/.local/state/nix/profiles/home-manager/home-path/bin
        fish_add_path --prepend ~/.nix-profile/bin
        fish_add_path --prepend /nix/var/nix/profiles/default/bin
      ''}
    '';

    interactiveShellInit = ''
      # Set catppuccin flavor
      set -g catppuccin_flavor mocha

      # Source nix and home-manager profiles (Linux only - macOS uses nix-darwin)
      ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
        if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish
          source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
        end
      ''}

      # Add tool-specific paths
      fish_add_path "$HOME/.opencode/bin"
      fish_add_path "$HOME/.jjforge/bin"

      # Enable vi key bindings
      fish_vi_key_bindings

      # source secrets file if it exists
      test -f ~/.config/fish/secrets.fish && source ~/.config/fish/secrets.fish

      set -x VAULT_ADDR "https://vault.jjforge.cloud:8200"
      set -x VAULT_SKIP_VERIFY true
      set -gx NOTES "$HOME/CloudDocs/Notes"

      # Set LS_COLORS using vivid with catppuccin theme
      set -gx LS_COLORS (vivid generate catppuccin-mocha)
    '';

    shellAbbrs = {
      j = "jrnl";
      jl = "jrnl --format short";
      jf = "jrnl @fire";
      n = "notes";
      nw = "zellij --layout notes";
      vi = "hx";
      ls = "eza";
      ll = "eza -la --git";
      lt = "eza -T --level=2";
    };

    functions = {
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
          printf "  %-8s %s\n" "vi"   "Open helix editor"
          printf "  %-8s %s\n" "ls"   "List files with eza"
          printf "  %-8s %s\n" "ll"   "List files (long format with git)"
          printf "  %-8s %s\n" "lt"   "List files as tree (2 levels)"
          echo ""
          set_color --bold cyan
          echo "═══ Note Templates ═══"
          set_color normal
          echo ""
          printf "  %-12s %s\n" "today"     "Open or create today's daily note"
          printf "  %-12s %s\n" "daily"     "Create daily note template"
          printf "  %-12s %s\n" "weekly"    "Create weekly review template"
          printf "  %-12s %s\n" "quarterly" "Create quarterly review (usage: quarterly Q4 [year])"
          printf "  %-12s %s\n" "person"    "Create person profile template"
          printf "  %-12s %s\n" "project"   "Create project template"
          printf "  %-12s %s\n" "company"   "Create company research template"
          printf "  %-12s %s\n" "adr"       "Create architecture decision record"
          printf "  %-12s %s\n" "decision"  "Create decision document"
          printf "  %-12s %s\n" "incident"  "Create incident report template"
          echo ""
          set_color --bold cyan
          echo "═══ Search & Navigation ═══"
          set_color normal
          echo ""
          printf "  %-12s %s\n" "notes"     "Search notes or create new note"
          printf "  %-12s %s\n" "ft"        "Find tasks in notes (usage: ft [tag])"
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
          echo ""
        '';
      };

      person = {
        description = "Populate an md file for a person.";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: person <name>"
            return 1
          end

          set -l name $argv
          set -l id (string lower -- $name | string replace -a ' ' '-')

          echo "---"
          echo "id:$id"
          echo "aliases:"
          echo "  - $name"
          echo "tags: []"
          echo "---"
          echo ""
          echo "# $name"
          '';
      };

      project = {
        description = "Populate an md file for a project.";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: project <name>"
            return 1
          end

          set -l name $argv
          set -l id (string lower -- $name | string replace -a ' ' '-')

          echo "---"
          echo "id: $id"
          echo "aliases:"
          echo "  - $name"
          echo "tags: [project]"
          echo "---"
          echo ""
          echo "# $name"
          echo ""
          echo "## Overview"
          echo ""
          echo "## Goals"
          echo ""
          echo "## Stakeholders"
          echo ""
          echo "## Key Decisions"
          echo ""
          echo "## Risks"
          echo ""
          echo "## Status Updates"
        '';
      };

      adr = {
        description = "Populate an md file for an architecture decision record.";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: adr <name>"
            return 1
          end

          set -l name $argv
          set -l id (string lower -- $name | string replace -a ' ' '-')
          set -l today (date +%Y-%m-%d)

          echo "---"
          echo "id: adr-$id"
          echo "aliases:"
          echo "  - $name"
          echo "tags: [adr]"
          echo "date: $today"
          echo "status: proposed"
          echo "---"
          echo ""
          echo "# $name"
          echo ""
          echo "## Status"
          echo ""
          echo "Proposed"
          echo ""
          echo "## Context"
          echo ""
          echo "## Options Considered"
          echo ""
          echo "### Option 1"
          echo ""
          echo "### Option 2"
          echo ""
          echo "## Decision"
          echo ""
          echo "## Consequences"
        '';
      };

      weekly = {
        description = "Populate an md file for a weekly review.";
        body = ''
          set -l today (date +%Y-%m-%d)
          set -l formatted (date +"%B %-d, %Y")
    
          echo "---"
          echo "id: weekly-$today"
          echo "aliases:"
          echo "  - Week of $formatted"
          echo "tags: [weekly-review]"
          echo "---"
          echo ""
          echo "# Week of $formatted"
          echo ""
          echo "## Wins"
          echo ""
          echo "## Challenges"
          echo ""
          echo "## Next Week Priorities"
          echo ""
          echo "## Notes"
        '';
      };

      quarterly = {
        description = "Populate an md file for a quarterly review. Usage: quarterly Q4 [year]";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: quarterly <quarter> [year]"
            echo "Example: quarterly Q4 2024"
            return 1
          end

          set -l quarter $argv[1]
          set -l year (date +%Y)
          if test (count $argv) -gt 1
              set year $argv[2]
          end

          echo "---"
          echo "id: $year-$quarter-review"
          echo "aliases:"
          echo "  - $quarter $year Review"
          echo "tags: [quarterly-review]"
          echo "---"
          echo ""
          echo "# $quarter $year Review"
          echo ""
          echo "## Goals"
          echo ""
          echo "## Accomplishments"
          echo ""
          echo "## What Worked"
          echo ""
          echo "## What Didn't"
          echo ""
          echo "## Key Learnings"
          echo ""
          echo "## Next Quarter Priorities"
        '';
      };

      decision = {
        description = "Populate an md file for a decision document.";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: decision <name>"
            return 1
          end

          set -l name $argv
          set -l id (string lower -- $name | string replace -a ' ' '-')
          set -l today (date +%Y-%m-%d)

          echo "---"
          echo "id: decision-$id"
          echo "aliases:"
          echo "  - $name"
          echo "tags: [decision]"
          echo "date: $today"
          echo "status: draft"
          echo "---"
          echo ""
          echo "# $name"
          echo ""
          echo "## Problem Statement"
          echo ""
          echo "## Options"
          echo ""
          echo "### Option 1"
          echo ""
          echo "**Pros:**"
          echo ""
          echo "**Cons:**"
          echo ""
          echo "### Option 2"
          echo ""
          echo "**Pros:**"
          echo ""
          echo "**Cons:**"
          echo ""
          echo "## Recommendation"
          echo ""
          echo "## Tradeoffs"
          echo ""
          echo "## Decision"
        '';
      };

      incident = {
        description = "Populate an md file for an incident report.";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: incident <name>"
            return 1
          end

          set -l name $argv
          set -l id (string lower -- $name | string replace -a ' ' '-')
          set -l today (date +%Y-%m-%d)
          set -l now (date +%H:%M)

          echo "---"
          echo "id: incident-$today-$id"
          echo "aliases:"
          echo "  - $name"
          echo "tags: [incident]"
          echo "date: $today"
          echo "severity: "
          echo "status: investigating"
          echo "---"
          echo ""
          echo "# $name"
          echo ""
          echo "## Timeline"
          echo ""
          echo "- $now - Incident identified"
          echo ""
          echo "## Impact"
          echo ""
          echo "## Root Cause"
          echo ""
          echo "## Resolution"
          echo ""
          echo "## Action Items"
          echo ""
          echo "## Prevention"
        '';
      };

      company = {
        description = "Populate an md file for company research.";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: company <name>"
            return 1
          end

          set -l name $argv
          set -l id (string lower -- $name | string replace -a ' ' '-')
          set -l today (date +%Y-%m-%d)

          echo "---"
          echo "id: company-$id"
          echo "aliases:"
          echo "  - $name"
          echo "tags: [company-research]"
          echo "date: $today"
          echo "---"
          echo ""
          echo "# $name"
          echo ""
          echo "## Overview"
          echo ""
          echo "## Leadership"
          echo ""
          echo "## Culture Signals"
          echo ""
          echo "## Tech Stack & Challenges"
          echo ""
          echo "## Role Details"
          echo ""
          echo "## Compensation"
          echo ""
          echo "## Concerns"
          echo ""
          echo "## Questions to Ask"
          echo ""
          echo "## Verdict"
        '';
      };

      daily = {
        description = "Populate an md file for a daily note.";
        body = ''
          set -l today (date +%Y-%m-%d)
          set -l formatted (date +"%A %B %-d, %Y")
    
          echo "---"
          echo "id: $today"
          echo "aliases:"
          echo "  - $today"
          echo "tags: []"
          echo "---"
          echo ""
          echo "# $formatted"
          echo ""
          echo "## Meetings"
          echo ""
          echo "## Notes"
        '';
      };

      today = {
        description = "Open or create today's daily note";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end
          if not test -d "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES directory does not exist: $NOTES"
            return 1
          end

          set -l filepath "$NOTES/"(date +%Y-%m-%d)".md"

          if not test -e "$filepath"
            daily > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      # ft = {
      #   description = "Find tasks in notes";
      #   body = ''
      #     if not set -q NOTES; or test -z "$NOTES"
      #       echo -e "\033[31mError:\033[0m NOTES environment variable not set"
      #       return 1
      #     end
      #     if not test -d "$NOTES"
      #       echo -e "\033[31mError:\033[0m NOTES directory does not exist: $NOTES"
      #       return 1
      #     end

      #     rg --vimgrep -o -P '(?=.*\[ \])(?=.*#weekly).*' $NOTES | awk -F: '{print $4 ":" $1 ":" $2}' | fzf --ansi --delimiter ':' --with-nth=1 --bind "enter:execute($EDITOR {2}:{3})" --height 7
      #   '';
      # };

ft = {
  description = "Find tasks in notes";
  body = ''
    if not set -q NOTES; or test -z "$NOTES"
      echo -e "\033[31mError:\033[0m NOTES environment variable not set"
      return 1
    end
    if not test -d "$NOTES"
      echo -e "\033[31mError:\033[0m NOTES directory does not exist: $NOTES"
      return 1
    end

    set -l pattern '\[ \].*'
    if test (count $argv) -gt 0
      set pattern "(?=.*\[ \])(?=.*$argv[1]).*"
    end

    set -l prev_dir $PWD
    cd $NOTES
    rg --vimgrep -o -P $pattern $NOTES | awk -F: '{print $4 ":" $1 ":" $2}' | fzf --ansi --delimiter ':' --with-nth=1 --bind "enter:execute($EDITOR {2}:{3})"
    cd $prev_dir
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

      notes = {
        description = "Search notes or create new note";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end
          if not test -d "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES directory does not exist: $NOTES"
            return 1
          end

          set -l prev_dir $PWD
          cd $NOTES

          set -l selected (fd --type f --extension md . "$NOTES" | \
            fzf --print-query \
                --preview "head -50 {}" \
                --preview-window=right:50%:wrap \
                --height=80% \
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
            set -l filename (string lower -- "$search_query" | string replace -a " " "-")".md"
            set -l filepath "$NOTES/$filename"

            if test -e "$filepath"
              echo "File already exists: $filepath"
              $EDITOR "$filepath"
            else
              echo "# $search_query" > "$filepath"
              echo "Created: $filepath"
              $EDITOR "$filepath"
            end
          end
          cd $prev_dir
        '';
      };

      sn = {
        description = "Search inside notes by content";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end
          if not test -d "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES directory does not exist: $NOTES"
            return 1
          end

          set -l prev_dir $PWD
          cd $NOTES

          set -l query (string join " " -- $argv)
          set -l selection (rg --color=always --line-number --no-heading --smart-case -- "$query" "$NOTES" | \
            fzf --ansi \
                --delimiter : \
                --preview "bat --force-colorization --highlight-line {2} {1}" \
                --preview-window=right:50%:wrap \
                --height=80%)

          if test -n "$selection"
            set -l file (echo "$selection" | string split -f1 :)
            set -l line (echo "$selection" | string split -f2 :)
            $EDITOR "+$line" "$file"
          end
          cd $prev_dir
        '';
      };
    };

    plugins = [
      {
        name = "catppuccin";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "af622a6e247806f6260c00c6d261aa22680e5201";
          hash = "sha256-KD/sWXSXYVlV+n7ft4vKFYpIMBB3PSn6a6jz+ZIMZvQ=";
        };
      }
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
  };
}
