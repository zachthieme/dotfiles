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
        fish_add_path --prepend $HOME/.cargo/bin
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
      fw = "ft '#weekly'";
      fo = "overdue";
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
          printf "  %-12s %s\n" "daily"     "Create/open today's daily note (daily/)"
          printf "  %-12s %s\n" "weekly"    "Create/open weekly review (weekly/)"
          printf "  %-12s %s\n" "quarterly" "Create quarterly review (quarterly/)"
          printf "  %-12s %s\n" "person"    "Create person profile (people/)"
          printf "  %-12s %s\n" "project"   "Create project note (projects/)"
          printf "  %-12s %s\n" "company"   "Create company research (companies/)"
          printf "  %-12s %s\n" "adr"       "Create architecture decision record (adrs/)"
          printf "  %-12s %s\n" "decision"  "Create decision document (decisions/)"
          printf "  %-12s %s\n" "incident"  "Create incident report (incidents/)"
          echo ""
          set_color --bold cyan
          echo "═══ Search & Navigation ═══"
          set_color normal
          echo ""
          printf "  %-12s %s\n" "notes"     "Search notes or create new note"
          printf "  %-12s %s\n" "ft"        "Find tasks in notes (usage: ft [tag])"
          printf "  %-12s %s\n" "fw"        "Find weekly tasks (ft #weekly)"
          printf "  %-12s %s\n" "overdue"   "Find overdue tasks (unchecked with past due dates)"
          printf "  %-12s %s\n" "fo"        "Find overdue tasks (overdue)"
          printf "  %-12s %s\n" "nw"        "Open notes workspace (commits & pushes on close)"
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
          printf "  %-12s %s\n" "migrate-ids" "Replace non-GUID note ids with UUIDs"
          echo ""
        '';
      };

      person = {
        description = "Create a person profile note in people/";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: person <name>"
            return 1
          end
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          set -l name $argv
          set -l slug (string lower -- $name | string replace -a ' ' '-')
          set -l dir "$NOTES/people"
          set -l filepath "$dir/$slug.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            set -l id (uuidgen)
            echo "---
id: $id
aliases:
  - $name
tags: []
---

# $name" > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      project = {
        description = "Create a project note in projects/";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: project <name>"
            return 1
          end
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          set -l name $argv
          set -l slug (string lower -- $name | string replace -a ' ' '-')
          set -l dir "$NOTES/projects"
          set -l filepath "$dir/$slug.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            set -l id (uuidgen)
            echo "---
id: $id
aliases:
  - $name
tags: [project]
---

# $name

## Overview

## Goals

## Stakeholders

## Key Decisions

## Risks

## Status Updates" > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      adr = {
        description = "Create an architecture decision record in adrs/";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: adr <name>"
            return 1
          end
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          set -l name $argv
          set -l slug (string lower -- $name | string replace -a ' ' '-')
          set -l dir "$NOTES/adrs"
          set -l filepath "$dir/$slug.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            set -l id (uuidgen)
            set -l today (date +%Y-%m-%d)
            echo "---
id: $id
aliases:
  - $name
tags: [adr]
date: $today
status: proposed
---

# $name

## Status

Proposed

## Context

## Options Considered

### Option 1

### Option 2

## Decision

## Consequences" > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      weekly = {
        description = "Create a weekly review note in weekly/";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          set -l today (date +%Y-%m-%d)
          set -l formatted (date +"%B %-d, %Y")
          set -l dir "$NOTES/weekly"
          set -l filepath "$dir/$today.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            echo "---
id: weekly-$today
aliases:
  - Week of $formatted
tags: [weekly-review]
---

# Week of $formatted

## Wins

## Challenges

## Next Week Priorities

## Notes" > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      quarterly = {
        description = "Create a quarterly review note in quarterly/. Usage: quarterly Q4 [year]";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: quarterly <quarter> [year]"
            echo "Example: quarterly Q4 2024"
            return 1
          end
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          set -l quarter $argv[1]
          set -l year (date +%Y)
          if test (count $argv) -gt 1
            set year $argv[2]
          end

          set -l dir "$NOTES/quarterly"
          set -l filepath "$dir/$year-$quarter.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            echo "---
id: $year-$quarter-review
aliases:
  - $quarter $year Review
tags: [quarterly-review]
---

# $quarter $year Review

## Goals

## Accomplishments

## What Worked

## What Didn't

## Key Learnings

## Next Quarter Priorities" > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      decision = {
        description = "Create a decision document in decisions/";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: decision <name>"
            return 1
          end
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          set -l name $argv
          set -l slug (string lower -- $name | string replace -a ' ' '-')
          set -l dir "$NOTES/decisions"
          set -l filepath "$dir/$slug.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            set -l id (uuidgen)
            set -l today (date +%Y-%m-%d)
            echo "---
id: $id
aliases:
  - $name
tags: [decision]
date: $today
status: draft
---

# $name

## Problem Statement

## Options

### Option 1

**Pros:**

**Cons:**

### Option 2

**Pros:**

**Cons:**

## Recommendation

## Tradeoffs

## Decision" > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      incident = {
        description = "Create an incident report in incidents/";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: incident <name>"
            return 1
          end
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          set -l name $argv
          set -l slug (string lower -- $name | string replace -a ' ' '-')
          set -l dir "$NOTES/incidents"
          set -l filepath "$dir/$slug.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            set -l id (uuidgen)
            set -l today (date +%Y-%m-%d)
            set -l now (date +%H:%M)
            echo "---
id: $id
aliases:
  - $name
tags: [incident]
date: $today
severity:
status: investigating
---

# $name

## Timeline

- $now - Incident identified

## Impact

## Root Cause

## Resolution

## Action Items

## Prevention" > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      company = {
        description = "Create a company research note in companies/";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: company <name>"
            return 1
          end
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          set -l name $argv
          set -l slug (string lower -- $name | string replace -a ' ' '-')
          set -l dir "$NOTES/companies"
          set -l filepath "$dir/$slug.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            set -l id (uuidgen)
            set -l today (date +%Y-%m-%d)
            echo "---
id: $id
aliases:
  - $name
tags: [company-research]
date: $today
---

# $name

## Overview

## Leadership

## Culture Signals

## Tech Stack & Challenges

## Role Details

## Compensation

## Concerns

## Questions to Ask

## Verdict" > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      daily = {
        description = "Create or open today's daily note in daily/";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          set -l today (date +%Y-%m-%d)
          set -l formatted (date +"%A %B %-d, %Y")
          set -l dir "$NOTES/daily"
          set -l filepath "$dir/$today.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            echo "---
id: $today
aliases:
  - $today
tags: []
---

# $formatted

## Meetings

## Notes" > "$filepath"
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

      overdue = {
        description = "Find overdue tasks in notes (unchecked tasks with past ISO 8601 due dates)";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end
          if not test -d "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES directory does not exist: $NOTES"
            return 1
          end

          set -l today (date +%Y-%m-%d)
          set -l prev_dir $PWD
          cd $NOTES
          rg --vimgrep -o -P '(?=.*\[ \])(?=.*\d{4}-\d{2}-\d{2}).*' $NOTES | \
            awk -F: -v today="$today" '{
              if (match($4, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) {
                d = substr($4, RSTART, RLENGTH)
                if (d < today) {
                  print $4 ":" $1 ":" $2
                }
              }
            }' | \
            fzf --ansi --delimiter ':' --with-nth=1 --bind "enter:execute($EDITOR {2}:{3})"
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

      migrate-ids = {
        description = "Replace non-GUID ids in note frontmatter with UUIDs";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

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
            awk -v new_id="$new_id" '/^id:/ && !done {print "id: " new_id; done=1; next} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            echo "  $file: $id_value → $new_id"
            set count (math $count + 1)
          end

          if test $count -eq 0
            echo "All notes already have GUID ids."
          else
            echo "Updated $count note(s)."
          end
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

      _hx_toggle_task = {
        description = "Toggle task checkbox with @completed date (used by helix :pipe)";
        body = ''
          set -l d (date +%Y-%m-%d)
          while read -l line
            if string match -qr '^\s*- \[ \] ' -- "$line"
              set -l toggled (string replace -- '- [ ] ' '- [x] ' "$line")
              set -l cleaned (string replace -r ' *@completed\(\d{4}-\d{2}-\d{2}\)' '''' -- "$toggled")
              echo "$cleaned @completed($d)"
            else if string match -qr '^\s*- \[[xX]\] ' -- "$line"
              set -l toggled (string replace -r -- '- \[[xX]\] ' '- [ ] ' "$line")
              set -l cleaned (string replace -r ' *@completed\(\d{4}-\d{2}-\d{2}\)' '''' -- "$toggled")
              echo "$cleaned"
            else
              echo "$line"
            end
          end
        '';
      };

      nw = {
        description = "Open notes workspace, commit and push on close";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end

          zellij --layout notes

          # After zellij exits, commit and push notes via jj
          set -l prev_dir $PWD
          cd $NOTES

          if jj root &>/dev/null
            set -l changes (jj diff --stat 2>/dev/null)
            if test -n "$changes"
              set -l today (date "+%Y-%m-%d %H:%M")
              jj commit -m "notes: auto-save $today"
              echo -e "\033[32mCommitted notes changes.\033[0m"
            else
              echo "No changes to commit."
            end
            jj git push 2>/dev/null
            and echo -e "\033[32mPushed to remote.\033[0m"
            or echo -e "\033[33mPush skipped (no remote or nothing to push).\033[0m"
          else
            echo -e "\033[33mNotes directory is not a jj repository, skipping commit/push.\033[0m"
          end

          cd $prev_dir
        '';
      };

      sn = {
        description = "Search inside notes by content";
        body = ''
          argparse 'n/no-preview' -- $argv; or return 1

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

          set -l fzf_opts --ansi --delimiter : --height=80%
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
