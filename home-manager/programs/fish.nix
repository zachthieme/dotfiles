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
      fw = "ft '@weekly|@today'";
      fo = "overdue";
      fu = "upcoming";
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
          printf "  %-8s %s\n" "n"    "Search/create notes (→ notes)"
          printf "  %-8s %s\n" "fw"   "Find weekly/today tasks (→ ft '@weekly|@today')"
          printf "  %-8s %s\n" "fo"   "Find overdue tasks (→ overdue)"
          printf "  %-8s %s\n" "fu"   "Find upcoming tasks (→ upcoming)"
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
          printf "  %-12s %s\n" "ft"         "Find tasks by tag (usage: ft [tag])"
          printf "  %-12s %s\n" "overdue"    "Find overdue tasks (past due dates)"
          printf "  %-12s %s\n" "completed"  "Find recently completed tasks (completed [days])"
          printf "  %-12s %s\n" "upcoming"   "Find tasks due soon (upcoming [days])"
          printf "  %-12s %s\n" "td"         "Show task summary dashboard"
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

      person = {
        description = "Create a person profile note in people/";
        body = ''
          if test (count $argv) -eq 0
            echo "Usage: person <name>"
            return 1
          end
          _require_notes; or return 1

          set -l name $argv
          set -l slug (_slugify $name)
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
          _require_notes; or return 1

          set -l name $argv
          set -l slug (_slugify $name)
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
          _require_notes; or return 1

          set -l name $argv
          set -l slug (_slugify $name)
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
          _require_notes; or return 1

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
          _require_notes; or return 1

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
          _require_notes; or return 1

          set -l name $argv
          set -l slug (_slugify $name)
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
          _require_notes; or return 1

          set -l name $argv
          set -l slug (_slugify $name)
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
          _require_notes; or return 1

          set -l name $argv
          set -l slug (_slugify $name)
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
          _require_notes; or return 1

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

      ft = {
        description = "Find tasks in notes";
        body = ''
          _require_notes_dir; or return 1
          argparse 't/test' -- $argv; or return 1

          set -l pattern '\[ \].*'
          if test (count $argv) -gt 0
            set pattern "(?=.*\[ \])(?=.*(?:$argv[1])).*"
          end

          set -l prev_dir $PWD
          cd $NOTES
          set -l results (rg --vimgrep -o -P $pattern $NOTES | awk -F: '{print $4 ":" $1 ":" $2}')
          if set -q _flag_test
            printf '%s\n' $results
          else
            printf '%s\n' $results | fzf --ansi --delimiter ':' --with-nth=1 --height=100% --layout=reverse --border none --no-separator --no-info --bind "enter:execute($EDITOR {2}:{3})"
          end
          cd $prev_dir
        '';
      };

      overdue = {
        description = "Find overdue tasks in notes (unchecked tasks with past ISO 8601 due dates)";
        body = ''
          _require_notes_dir; or return 1
          argparse 't/test' -- $argv; or return 1

          set -l today (date +%Y-%m-%d)
          set -l prev_dir $PWD
          cd $NOTES
          set -l results (rg --vimgrep -o -P '(?=.*\[ \])(?=.*@due\(\d{4}-\d{2}-\d{2}\)).*' $NOTES | \
            awk -F: -v today="$today" '{
              if (match($4, /@due\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)/)) {
                d = substr($4, RSTART+5, 10)
                if (d < today) {
                  print $4 ":" $1 ":" $2
                }
              }
            }')
          if set -q _flag_test
            printf '%s\n' $results
          else
            printf '%s\n' $results | fzf --ansi --delimiter ':' --with-nth=1 --height=100% --layout=reverse --border none --no-separator --no-info --bind "enter:execute($EDITOR {2}:{3})"
          end
          cd $prev_dir
        '';
      };

      completed = {
        description = "Find recently completed tasks (default: last 7 days)";
        body = ''
          _require_notes_dir; or return 1
          argparse 't/test' -- $argv; or return 1

          set -l days 7
          if test (count $argv) -gt 0
            set days $argv[1]
          end

          set -l cutoff
          if _is_gnu_date
            set cutoff (date -d "$days days ago" +%Y-%m-%d)
          else
            set cutoff (date -v-{$days}d +%Y-%m-%d)
          end

          set -l prev_dir $PWD
          cd $NOTES
          set -l results (rg --vimgrep -o -P '(?=.*\[[xX]\])(?=.*@completed\(\d{4}-\d{2}-\d{2}\)).*' $NOTES | \
            awk -F: -v cutoff="$cutoff" '{
              if (match($4, /@completed\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)/)) {
                d = substr($4, RSTART+11, 10)
                if (d >= cutoff) {
                  print $4 ":" $1 ":" $2
                }
              }
            }')
          if set -q _flag_test
            printf '%s\n' $results
          else
            printf '%s\n' $results | fzf --ansi --delimiter ':' --with-nth=1 --height=100% --layout=reverse --border none --no-separator --no-info --bind "enter:execute($EDITOR {2}:{3})"
          end
          cd $prev_dir
        '';
      };

      upcoming = {
        description = "Find tasks due within N days (default: 7)";
        body = ''
          _require_notes_dir; or return 1
          argparse 't/test' -- $argv; or return 1

          set -l days 7
          if test (count $argv) -gt 0
            set days $argv[1]
          end

          set -l today (date +%Y-%m-%d)
          set -l horizon
          if _is_gnu_date
            set horizon (date -d "+$days days" +%Y-%m-%d)
          else
            set horizon (date -v+{$days}d +%Y-%m-%d)
          end

          set -l prev_dir $PWD
          cd $NOTES
          set -l results (rg --vimgrep -o -P '(?=.*\[ \])(?=.*@due\(\d{4}-\d{2}-\d{2}\)).*' $NOTES | \
            awk -F: -v today="$today" -v horizon="$horizon" '{
              if (match($4, /@due\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)/)) {
                d = substr($4, RSTART+5, 10)
                if (d >= today && d <= horizon) {
                  print $4 ":" $1 ":" $2
                }
              }
            }')
          if set -q _flag_test
            printf '%s\n' $results
          else
            printf '%s\n' $results | fzf --ansi --delimiter ':' --with-nth=1 --height=100% --layout=reverse --border none --no-separator --no-info --bind "enter:execute($EDITOR {2}:{3})"
          end
          cd $prev_dir
        '';
      };

      td = {
        description = "Show task summary dashboard";
        body = ''
          _require_notes_dir; or return 1

          set -l today (date +%Y-%m-%d)
          set -l week_horizon
          set -l week_cutoff
          if _is_gnu_date
            set week_horizon (date -d "+7 days" +%Y-%m-%d)
            set week_cutoff (date -d "7 days ago" +%Y-%m-%d)
          else
            set week_horizon (date -v+7d +%Y-%m-%d)
            set week_cutoff (date -v-7d +%Y-%m-%d)
          end

          set -l open (rg -c '\[ \]' $NOTES --glob '*.md' | awk -F: '{s+=$2} END {print s+0}')
          set -l overdue_count (rg --no-filename -o -P '(?=.*\[ \])(?=.*@due\(\d{4}-\d{2}-\d{2}\)).*' $NOTES --glob '*.md' | \
            awk -v today="$today" '{
              if (match($0, /@due\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)/)) {
                d = substr($0, RSTART+5, 10)
                if (d < today) count++
              }
            } END {print count+0}')
          set -l due_week (rg --no-filename -o -P '(?=.*\[ \])(?=.*@due\(\d{4}-\d{2}-\d{2}\)).*' $NOTES --glob '*.md' | \
            awk -v today="$today" -v horizon="$week_horizon" '{
              if (match($0, /@due\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)/)) {
                d = substr($0, RSTART+5, 10)
                if (d >= today && d <= horizon) count++
              }
            } END {print count+0}')
          set -l done_week (rg --no-filename -o -P '(?=.*\[[xX]\])(?=.*@completed\(\d{4}-\d{2}-\d{2}\)).*' $NOTES --glob '*.md' | \
            awk -v cutoff="$week_cutoff" '{
              if (match($0, /@completed\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)/)) {
                d = substr($0, RSTART+11, 10)
                if (d >= cutoff) count++
              }
            } END {print count+0}')

          echo ""
          set_color --bold cyan
          echo "═══ Task Summary ═══"
          set_color normal
          echo ""
          printf "  %-24s %s\n" "Open tasks" "$open"
          if test "$overdue_count" -gt 0
            printf "  %-24s \033[31m%s\033[0m\n" "Overdue" "$overdue_count"
          else
            printf "  %-24s %s\n" "Overdue" "$overdue_count"
          end
          printf "  %-24s %s\n" "Due this week" "$due_week"
          printf "  %-24s %s\n" "Completed this week" "$done_week"
          echo ""
        '';
      };

      review = {
        description = "Generate a review (weekly, monthly, quarterly) pre-filled with tasks for LLM analysis";
        body = ''
          _require_notes_dir; or return 1

          set -l period weekly
          if test (count $argv) -gt 0
            set period $argv[1]
          end

          set -l start_date
          set -l end_date
          set -l title
          set -l filepath
          set -l dir "$NOTES/reviews"
          set -l tag_label

          switch $period
            case weekly
              # Last full week: Sunday to Saturday
              set -l dow (date +%w)
              set -l sat_offset (math $dow + 1)
              set -l sun_offset (math $dow + 7)

              if _is_gnu_date
                set start_date (date -d "-$sun_offset days" +%Y-%m-%d)
                set end_date (date -d "-$sat_offset days" +%Y-%m-%d)
              else
                set start_date (date -v-{$sun_offset}d +%Y-%m-%d)
                set end_date (date -v-{$sat_offset}d +%Y-%m-%d)
              end

              set title "Weekly Review: $start_date to $end_date"
              set filepath "$dir/week-$start_date.md"
              set tag_label "@weekly"

            case monthly
              # Last full calendar month
              if _is_gnu_date
                set -l first_of_month (date +%Y-%m-01)
                set start_date (date -d "$first_of_month - 1 month" +%Y-%m-%d)
                set end_date (date -d "$first_of_month - 1 day" +%Y-%m-%d)
              else
                set start_date (date -v1d -v-1m +%Y-%m-%d)
                set end_date (date -v1d -v-1d +%Y-%m-%d)
              end

              set -l ym (string sub -l 7 $start_date)
              set title "Monthly Review: $ym"
              set filepath "$dir/month-$ym.md"
              set tag_label "@weekly / @monthly"

            case quarterly
              # Last full fiscal quarter (Q1=Oct-Dec, Q2=Jan-Mar, Q3=Apr-Jun, Q4=Jul-Sep)
              set -l month (date +%-m)
              set -l year (date +%Y)
              set -l q_start_month
              set -l q_end_month
              set -l q_year
              set -l q_label
              set -l fy_year

              if test $month -ge 10
                # In Q1 (Oct-Dec): last full = Q4 Jul-Sep same year
                set q_start_month 7; set q_end_month 9; set q_year $year; set q_label Q4
              else if test $month -ge 7
                # In Q4 (Jul-Sep): last full = Q3 Apr-Jun same year
                set q_start_month 4; set q_end_month 6; set q_year $year; set q_label Q3
              else if test $month -ge 4
                # In Q3 (Apr-Jun): last full = Q2 Jan-Mar same year
                set q_start_month 1; set q_end_month 3; set q_year $year; set q_label Q2
              else
                # In Q2 (Jan-Mar): last full = Q1 Oct-Dec previous year
                set q_start_month 10; set q_end_month 12; set q_year (math $year - 1); set q_label Q1
              end

              # Fiscal year label (Q1 Oct 2025 = FY2026)
              if test $q_start_month -ge 10
                set fy_year (math $q_year + 1)
              else
                set fy_year $q_year
              end

              set start_date (printf "%04d-%02d-01" $q_year $q_start_month)
              switch $q_end_month
                case 3 12
                  set end_date (printf "%04d-%02d-31" $q_year $q_end_month)
                case 6 9
                  set end_date (printf "%04d-%02d-30" $q_year $q_end_month)
              end

              set title "$q_label FY$fy_year Review: $start_date to $end_date"
              set filepath "$dir/quarter-$q_label-fy$fy_year.md"
              set tag_label "@weekly / @monthly / @quarterly"

            case '*'
              echo "Usage: review [weekly|monthly|quarterly]"
              return 1
          end

          mkdir -p "$dir"

          if test -e "$filepath"
            set -l prev_dir $PWD
            cd $NOTES
            $EDITOR "$filepath"
            cd $prev_dir
            return 0
          end

          # Gather completed tasks in the period
          set -l completed_tasks (rg --no-filename -o -P '(?=.*\[[xX]\])(?=.*@completed\(\d{4}-\d{2}-\d{2}\)).*' $NOTES --glob '*.md' 2>/dev/null | \
            awk -v start="$start_date" -v end_date="$end_date" '{
              if (match($0, /@completed\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)/)) {
                d = substr($0, RSTART+11, 10)
                if (d >= start && d <= end_date) print
              }
            }')

          # Gather overdue tasks
          set -l today (date +%Y-%m-%d)
          set -l overdue_tasks (rg --no-filename -o -P '(?=.*\[ \])(?=.*@due\(\d{4}-\d{2}-\d{2}\)).*' $NOTES --glob '*.md' 2>/dev/null | \
            awk -v today="$today" '{
              if (match($0, /@due\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)/)) {
                d = substr($0, RSTART+5, 10)
                if (d < today) print
              }
            }')

          # Gather open tagged tasks
          set -l tagged_tasks
          switch $period
            case weekly
              set tagged_tasks (rg --no-filename -o -P '(?=.*\[ \])(?=.*@weekly).*' $NOTES --glob '*.md' 2>/dev/null)
            case monthly quarterly
              set tagged_tasks (rg --no-filename -o -P '(?=.*\[ \])(?=.*@(?:weekly|monthly|quarterly)).*' $NOTES --glob '*.md' 2>/dev/null)
          end

          # Build the review document with structured metadata for LLM analysis
          set -l id (uuidgen)
          echo "---
id: $id
tags: [review, $period]
start: $start_date
end: $end_date
---

# $title

## Completed Tasks
" > "$filepath"

          if test (count $completed_tasks) -gt 0
            printf '%s\n' $completed_tasks >> "$filepath"
          else
            echo "_No completed tasks._" >> "$filepath"
          end

          printf "\n## Overdue\n\n" >> "$filepath"

          if test (count $overdue_tasks) -gt 0
            printf '%s\n' $overdue_tasks >> "$filepath"
          else
            echo "_No overdue tasks._" >> "$filepath"
          end

          printf "\n## %s Tasks\n\n" "$tag_label" >> "$filepath"

          if test (count $tagged_tasks) -gt 0
            printf '%s\n' $tagged_tasks >> "$filepath"
          else
            echo "_No tagged tasks._" >> "$filepath"
          end

          printf "\n## Reflections\n\n## Key Themes\n\n## Next Period Priorities\n\n" >> "$filepath"
          printf "***\n\n" >> "$filepath"
          echo "*Analyze this $period review and identify: key accomplishments and their impact, patterns in completed vs overdue work, recurring themes, suggested priorities for next period, and areas of concern.*" >> "$filepath"

          echo "Created: $filepath"

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
          cd $prev_dir
        '';
      };

      monthly = {
        description = "Create a monthly review note in monthly/";
        body = ''
          _require_notes; or return 1

          set -l month (date +%Y-%m)
          set -l formatted (date +"%B %Y")
          set -l dir "$NOTES/monthly"
          set -l filepath "$dir/$month.md"
          mkdir -p "$dir"

          if not test -e "$filepath"
            set -l id (uuidgen)
            echo "---
id: $id
aliases:
  - $formatted Review
tags: [monthly-review]
---

# $formatted

## Highlights

## Completed

## Challenges

## Next Month Priorities

## Notes" > "$filepath"
            echo "Created: $filepath"
          end

          set -l prev_dir $PWD
          cd $NOTES
          $EDITOR "$filepath"
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
              set -l cleaned (string replace -r ' *@completed\(\d{4}-\d{2}-\d{2}\)' ''' -- "$toggled")
              echo "$cleaned @completed($d)"
            else if string match -qr '^\s*- \[[xX]\] ' -- "$line"
              set -l toggled (string replace -r -- '- \[[xX]\] ' '- [ ] ' "$line")
              set -l cleaned (string replace -r ' *@completed\(\d{4}-\d{2}-\d{2}\)' ''' -- "$toggled")
              echo "$cleaned"
            else
              echo "$line"
            end
          end
        '';
      };

      _require_notes = {
        description = "Check NOTES env var is set and non-empty";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end
        '';
      };

      _require_notes_dir = {
        description = "Check NOTES env var is set and directory exists";
        body = ''
          _require_notes; or return 1
          if not test -d "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES directory does not exist: $NOTES"
            return 1
          end
        '';
      };

      _slugify = {
        description = "Convert string to lowercase slug";
        body = ''
          string lower -- $argv | string replace -a ' ' '-'
        '';
      };

      _is_gnu_date = {
        description = "Test whether date is GNU coreutils (vs BSD)";
        body = ''
          date -d "1 day ago" +%Y-%m-%d &>/dev/null
        '';
      };

      notes-sync = {
        description = "Commit and push notes via jj";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            return 1
          end

          set -l prev_dir $PWD
          cd $NOTES

          if jj root &>/dev/null
            set -l changes (jj diff --summary 2>/dev/null)
            if test -n "$changes"
              set -l today (date "+%Y-%m-%d %H:%M")
              jj commit -m "notes: auto-save $today"
              echo -e "\033[32mCommitted notes changes.\033[0m"
              jj bookmark move main --to @-
              jj git push 2>/dev/null
              and echo -e "\033[32mPushed to remote.\033[0m"
              or echo -e "\033[33mPush skipped (no remote or nothing to push).\033[0m"
            else
              echo "No changes to commit."
            end
          else
            echo -e "\033[33mNotes directory is not a jj repository, skipping commit/push.\033[0m"
          end

          cd $prev_dir
        '';
      };

      nw = {
        description = "Open notes workspace, commit and push on close";
        body = ''
          _require_notes; or return 1

          if set -q ZELLIJ
            echo "Already inside a zellij session"
            return 1
          end

          zellij --layout ~/.config/zellij/layouts/notes.kdl attach --create notes

          # Final sync after zellij exits (catches anything panes missed)
          notes-sync
        '';
      };

      nwk = {
        description = "Kill the notes zellij session";
        body = ''
          zellij delete-session notes --force
        '';
      };

      sn = {
        description = "Search inside notes by content";
        body = ''
          argparse 'n/no-preview' -- $argv; or return 1
          _require_notes_dir; or return 1

          set -l prev_dir $PWD
          cd $NOTES

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
        '';
      };

      notes-test = {
        description = "Run tests for notes system functions";
        body = ''
          set -l pass 0
          set -l fail 0
          set -l _had_NOTES (set -q NOTES; and echo yes; or echo no)
          set -l _had_EDITOR (set -q EDITOR; and echo yes; or echo no)
          set -l _orig_NOTES "$NOTES"
          set -l _orig_EDITOR "$EDITOR"
          set -l tmpdir (mktemp -d)
          set -gx NOTES "$tmpdir"
          set -gx EDITOR true
          set -l today (date +%Y-%m-%d)

          echo ""
          set_color --bold cyan
          echo "═══ Notes Test Suite ═══"
          set_color normal

          # ── Helper Functions ──
          echo ""
          set_color --bold
          echo "Helper Functions"
          set_color normal

          # _slugify
          if test (_slugify "hello world") = "hello-world"
            set pass (math $pass + 1); echo "  ✓ _slugify basic"
          else
            set fail (math $fail + 1); echo "  ✗ _slugify basic"
          end

          if test (_slugify "My Cool Project") = "my-cool-project"
            set pass (math $pass + 1); echo "  ✓ _slugify multi-word"
          else
            set fail (math $fail + 1); echo "  ✗ _slugify multi-word"
          end

          if test (_slugify "already-hyphenated") = "already-hyphenated"
            set pass (math $pass + 1); echo "  ✓ _slugify already-hyphenated"
          else
            set fail (math $fail + 1); echo "  ✗ _slugify already-hyphenated"
          end

          # _is_gnu_date
          if _is_gnu_date 2>/dev/null
            set pass (math $pass + 1); echo "  ✓ _is_gnu_date detects GNU date"
          else
            set pass (math $pass + 1); echo "  ✓ _is_gnu_date detects BSD date"
          end

          # _require_notes
          if _require_notes >/dev/null 2>&1
            set pass (math $pass + 1); echo "  ✓ _require_notes with NOTES set"
          else
            set fail (math $fail + 1); echo "  ✗ _require_notes with NOTES set"
          end

          set -e NOTES
          if not _require_notes >/dev/null 2>&1
            set pass (math $pass + 1); echo "  ✓ _require_notes with NOTES unset"
          else
            set fail (math $fail + 1); echo "  ✗ _require_notes with NOTES unset"
          end
          set -gx NOTES "$tmpdir"

          # _require_notes_dir
          if _require_notes_dir >/dev/null 2>&1
            set pass (math $pass + 1); echo "  ✓ _require_notes_dir with valid dir"
          else
            set fail (math $fail + 1); echo "  ✗ _require_notes_dir with valid dir"
          end

          # _hx_toggle_task
          set -l checked (echo "- [ ] my task" | _hx_toggle_task)
          if test "$checked" = "- [x] my task @completed($today)"
            set pass (math $pass + 1); echo "  ✓ _hx_toggle_task check"
          else
            set fail (math $fail + 1); echo "  ✗ _hx_toggle_task check (got: $checked)"
          end

          set -l unchecked (echo "- [x] my task @completed($today)" | _hx_toggle_task)
          if test "$unchecked" = "- [ ] my task"
            set pass (math $pass + 1); echo "  ✓ _hx_toggle_task uncheck"
          else
            set fail (math $fail + 1); echo "  ✗ _hx_toggle_task uncheck (got: $unchecked)"
          end

          set -l passthrough (echo "regular line" | _hx_toggle_task)
          if test "$passthrough" = "regular line"
            set pass (math $pass + 1); echo "  ✓ _hx_toggle_task passthrough"
          else
            set fail (math $fail + 1); echo "  ✗ _hx_toggle_task passthrough (got: $passthrough)"
          end

          # ── Template Creation ──
          echo ""
          set_color --bold
          echo "Template Creation"
          set_color normal

          person "Test Person" >/dev/null 2>&1
          if test -e "$tmpdir/people/test-person.md"; and grep -q '^id:' "$tmpdir/people/test-person.md"
            set pass (math $pass + 1); echo "  ✓ person"
          else
            set fail (math $fail + 1); echo "  ✗ person"
          end

          project "Test Project" >/dev/null 2>&1
          if test -e "$tmpdir/projects/test-project.md"; and grep -q '^id:' "$tmpdir/projects/test-project.md"
            set pass (math $pass + 1); echo "  ✓ project"
          else
            set fail (math $fail + 1); echo "  ✗ project"
          end

          adr "Test ADR" >/dev/null 2>&1
          if test -e "$tmpdir/adrs/test-adr.md"; and grep -q '^id:' "$tmpdir/adrs/test-adr.md"
            set pass (math $pass + 1); echo "  ✓ adr"
          else
            set fail (math $fail + 1); echo "  ✗ adr"
          end

          decision "Test Decision" >/dev/null 2>&1
          if test -e "$tmpdir/decisions/test-decision.md"; and grep -q '^id:' "$tmpdir/decisions/test-decision.md"
            set pass (math $pass + 1); echo "  ✓ decision"
          else
            set fail (math $fail + 1); echo "  ✗ decision"
          end

          incident "Test Incident" >/dev/null 2>&1
          if test -e "$tmpdir/incidents/test-incident.md"; and grep -q '^id:' "$tmpdir/incidents/test-incident.md"
            set pass (math $pass + 1); echo "  ✓ incident"
          else
            set fail (math $fail + 1); echo "  ✗ incident"
          end

          company "Test Company" >/dev/null 2>&1
          if test -e "$tmpdir/companies/test-company.md"; and grep -q '^id:' "$tmpdir/companies/test-company.md"
            set pass (math $pass + 1); echo "  ✓ company"
          else
            set fail (math $fail + 1); echo "  ✗ company"
          end

          daily >/dev/null 2>&1
          if test -e "$tmpdir/daily/$today.md"; and grep -q '^id:' "$tmpdir/daily/$today.md"
            set pass (math $pass + 1); echo "  ✓ daily"
          else
            set fail (math $fail + 1); echo "  ✗ daily"
          end

          weekly >/dev/null 2>&1
          if test -e "$tmpdir/weekly/$today.md"; and grep -q '^id:' "$tmpdir/weekly/$today.md"
            set pass (math $pass + 1); echo "  ✓ weekly"
          else
            set fail (math $fail + 1); echo "  ✗ weekly"
          end

          set -l month (date +%Y-%m)
          monthly >/dev/null 2>&1
          if test -e "$tmpdir/monthly/$month.md"; and grep -q '^id:' "$tmpdir/monthly/$month.md"
            set pass (math $pass + 1); echo "  ✓ monthly"
          else
            set fail (math $fail + 1); echo "  ✗ monthly"
          end

          set -l year (date +%Y)
          quarterly Q1 $year >/dev/null 2>&1
          if test -e "$tmpdir/quarterly/$year-Q1.md"; and grep -q '^id:' "$tmpdir/quarterly/$year-Q1.md"
            set pass (math $pass + 1); echo "  ✓ quarterly"
          else
            set fail (math $fail + 1); echo "  ✗ quarterly"
          end

          # ── Task Search ──
          echo ""
          set_color --bold
          echo "Task Search"
          set_color normal

          # Create fixture data
          mkdir -p "$tmpdir/fixtures"
          set -l upcoming_date
          if _is_gnu_date
            set upcoming_date (date -d "+3 days" +%Y-%m-%d)
          else
            set upcoming_date (date -v+3d +%Y-%m-%d)
          end
          echo "# Test Tasks
- [ ] overdue task @due(2020-01-01)
- [ ] weekly task @weekly
- [ ] upcoming task @due($upcoming_date)
- [x] done task @completed($today)" > "$tmpdir/fixtures/tasks.md"

          # overdue --test
          set -l overdue_output (overdue --test 2>/dev/null)
          if string match -q '*overdue task*' -- "$overdue_output"
            set pass (math $pass + 1); echo "  ✓ overdue --test finds overdue task"
          else
            set fail (math $fail + 1); echo "  ✗ overdue --test finds overdue task"
          end

          # completed --test
          set -l completed_output (completed --test 9999 2>/dev/null)
          if string match -q '*done task*' -- "$completed_output"
            set pass (math $pass + 1); echo "  ✓ completed --test finds completed task"
          else
            set fail (math $fail + 1); echo "  ✗ completed --test finds completed task"
          end

          # upcoming --test
          set -l upcoming_output (upcoming --test 2>/dev/null)
          if string match -q '*upcoming task*' -- "$upcoming_output"
            set pass (math $pass + 1); echo "  ✓ upcoming --test finds upcoming task"
          else
            set fail (math $fail + 1); echo "  ✗ upcoming --test finds upcoming task"
          end

          # ft --test with tag filter
          set -l ft_output (ft --test '@weekly' 2>/dev/null)
          if string match -q '*weekly task*' -- "$ft_output"
            set pass (math $pass + 1); echo "  ✓ ft --test finds tagged task"
          else
            set fail (math $fail + 1); echo "  ✗ ft --test finds tagged task"
          end

          # td counts
          set -l td_output (td 2>/dev/null)
          if string match -q '*Open tasks*3*' -- "$td_output"
            set pass (math $pass + 1); echo "  ✓ td open count"
          else
            set fail (math $fail + 1); echo "  ✗ td open count"
          end
          if string match -q '*Overdue*1*' -- "$td_output"
            set pass (math $pass + 1); echo "  ✓ td overdue count"
          else
            set fail (math $fail + 1); echo "  ✗ td overdue count"
          end

          # review weekly
          review weekly >/dev/null 2>&1
          set -l review_file (find "$tmpdir/reviews" -name 'week-*.md' 2>/dev/null | head -1)
          if test -n "$review_file"; and grep -q 'Completed Tasks' "$review_file"; and grep -q 'Overdue' "$review_file"
            set pass (math $pass + 1); echo "  ✓ review weekly"
          else
            set fail (math $fail + 1); echo "  ✗ review weekly"
          end

          # ── Sync & Migration ──
          echo ""
          set_color --bold
          echo "Sync & Migration"
          set_color normal

          set -l sync_output (notes-sync 2>/dev/null)
          if string match -q '*not a jj repository*' -- "$sync_output"
            set pass (math $pass + 1); echo "  ✓ notes-sync handles non-jj dir"
          else
            set fail (math $fail + 1); echo "  ✗ notes-sync handles non-jj dir (got: $sync_output)"
          end

          mkdir -p "$tmpdir/migrate-test"
          echo "---
id: weekly-2024-01-01
tags: [test]
---
# Test" > "$tmpdir/migrate-test/test.md"
          migrate-ids >/dev/null 2>&1
          set -l new_id (awk '/^---$/{n++; next} n==1 && /^id:/{sub(/^id: */, ""); print; exit}' "$tmpdir/migrate-test/test.md")
          if string match -rq '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' -- "$new_id"
            set pass (math $pass + 1); echo "  ✓ migrate-ids replaces non-UUID ids"
          else
            set fail (math $fail + 1); echo "  ✗ migrate-ids replaces non-UUID ids (got: $new_id)"
          end

          # ── Teardown ──
          rm -rf "$tmpdir"
          if test "$_had_NOTES" = yes
            set -gx NOTES "$_orig_NOTES"
          else
            set -e NOTES
          end
          if test "$_had_EDITOR" = yes
            set -gx EDITOR "$_orig_EDITOR"
          else
            set -e EDITOR
          end

          # ── Summary ──
          echo ""
          set -l total (math $pass + $fail)
          if test $fail -eq 0
            set_color --bold green
            echo "All $total tests passed."
          else
            set_color --bold red
            echo "$fail of $total tests failed."
          end
          set_color normal
          echo ""

          return $fail
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
