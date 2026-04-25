# Fish functions for note creation, browsing, synchronization, and migration
{ ... }:

{
  programs.fish.functions = {
    person = {
      description = "Create a person profile note in people/";
      body = ''
        if test (count $argv) -eq 0
          echo "Usage: person <name>"
          return 1
        end
        _require_notes; or return 1

        set -l name (_titlecase $argv)
        set -l dir "$NOTES/people"
        set -l filepath "$dir/$name.md"
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

        set -l name (_titlecase $argv)
        set -l dir "$NOTES/projects"
        set -l filepath "$dir/$name.md"
        mkdir -p "$dir"

        if not test -e "$filepath"
          set -l id (uuidgen)
          echo "---
id: $id
aliases:
  - $name
tags: []
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
      description = "Create an architecture decision record in decisions/";
      body = ''
        if test (count $argv) -eq 0
          echo "Usage: adr <name>"
          return 1
        end
        _require_notes; or return 1

        set -l name (_titlecase $argv)
        set -l dir "$NOTES/decisions"
        set -l filepath "$dir/$name.md"
        mkdir -p "$dir"

        if not test -e "$filepath"
          set -l id (uuidgen)
          echo "---
id: $id
aliases:
  - $name
tags: []
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
      description = "Create a weekly review note in reviews/";
      body = ''
        _require_notes; or return 1

        set -l today (date +%Y-%m-%d)
        set -l formatted (date +"%B %-d, %Y")
        set -l dir "$NOTES/reviews"
        set -l filepath "$dir/$today.md"
        mkdir -p "$dir"

        if not test -e "$filepath"
          set -l id (uuidgen)
          echo "---
id: $id
aliases:
  - Week of $formatted
tags: []
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
          set -l id (uuidgen)
          echo "---
id: $id
aliases:
  - $quarter $year Review
tags: []
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

        set -l name (_titlecase $argv)
        set -l dir "$NOTES/decisions"
        set -l filepath "$dir/$name.md"
        mkdir -p "$dir"

        if not test -e "$filepath"
          set -l id (uuidgen)
          echo "---
id: $id
aliases:
  - $name
tags: []
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

        set -l name (_titlecase $argv)
        set -l dir "$NOTES/incidents"
        set -l filepath "$dir/$name.md"
        mkdir -p "$dir"

        if not test -e "$filepath"
          set -l id (uuidgen)
          set -l now (date +%H:%M)
          echo "---
id: $id
aliases:
  - $name
tags: []
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

        set -l name (_titlecase $argv)
        set -l dir "$NOTES/companies"
        set -l filepath "$dir/$name.md"
        mkdir -p "$dir"

        if not test -e "$filepath"
          set -l id (uuidgen)
          echo "---
id: $id
aliases:
  - $name
tags: []
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
          set -l id (uuidgen)
          echo "---
id: $id
aliases:
  - $formatted
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
tags: []
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

    nwk-tmux = {
      description = "Kill the notes tmux session";
      body = ''
        tmux kill-session -t notes 2>/dev/null
        and echo "Killed notes session."
        or echo "No notes session running."
      '';
    };

    nw-tmux = {
      description = "Open notes workspace in tmux, commit and push on close";
      body = ''
        _require_notes; or return 1

        if set -q TMUX
          echo "Already inside a tmux session"
          return 1
        end

        set -l notes_dir ~/CloudDocs/Notes
        set -l session notes

        # Attach if session already exists
        if tmux has-session -t $session 2>/dev/null
          tmux attach-session -t $session
          notes-sync
          return
        end

        # Tab 1: daily — right column is fixed, left column absorbs extra space
        #   pike        | wen cal (28 wide, 9 tall)
        #               | tick (14 tall)
        #   editor      | spacer
        # Create session at current terminal size so pane layout survives attach
        set -l cols (tput cols)
        set -l rows (tput lines)
        set -l pike_pane (tmux new-session -d -s $session -n daily -c $notes_dir -x $cols -y $rows -P -F '#{pane_id}')
        set -l wen_pane (tmux split-window -h -l 28 -t $pike_pane -c $notes_dir -P -F '#{pane_id}')
        set -l editor_pane (tmux split-window -v -t $pike_pane -c $notes_dir -P -F '#{pane_id}')
        tmux resize-pane -t $pike_pane -y 10
        set -l tick_pane (tmux split-window -v -t $wen_pane -c $notes_dir -P -F '#{pane_id}')
        tmux resize-pane -t $wen_pane -y 10
        tmux split-window -v -t $tick_pane -c $notes_dir "sleep infinity"
        tmux resize-pane -t $tick_pane -y 14

        # Pin right column to 28 wide on terminal resize
        tmux set-hook -t $session window-resized "resize-pane -t $wen_pane -x 28 ; resize-pane -t $tick_pane -x 28"

        tmux send-keys -t $pike_pane "pike -w priority" Enter
        tmux send-keys -t $wen_pane "wen cal" Enter
        tmux send-keys -t $editor_pane "daily; notes-sync" Enter
        tmux send-keys -t $tick_pane "tick --hosts 10950 --deadline 2026-09-30" Enter

        tmux select-pane -t $editor_pane

        # Tab 2: tasks — pike
        tmux new-window -t $session -n tasks -c $notes_dir
        tmux send-keys "pike" Enter

        # Tab 3: shell
        tmux new-window -t $session -n shell -c $notes_dir

        # Start on the daily tab
        tmux select-window -t $session:1

        tmux attach-session -t $session

        # Final sync after tmux exits
        notes-sync
      '';
    };

    _hx_ensure_note = {
      description = "Create a note from template if missing, write path to /tmp/hx_note_path (used by helix :pipe)";
      body = ''
        set -l type $argv[1]
        set -l input (cat)
        # Handle both [[Name]] (with brackets) and bare Name (selected inside brackets)
        set -l match (string match -r '\[\[([^\]]+)\]\]' -- $input)
        set -l name
        if test -n "$match[2]"
          set name $match[2]
        else
          set name (string trim -- $input)
        end

        if test -z "$name"; or not set -q NOTES; or test -z "$NOTES"
          echo -n $input
          return 1
        end

        switch $type
          case person
            set -l tname (_titlecase $name)
            set -l filepath "$NOTES/people/$tname.md"
            mkdir -p "$NOTES/people"
            if not test -e "$filepath"
              set -l id (uuidgen)
              printf "%s\n" "---" "id: $id" "aliases:" "  - $tname" "tags: []" "---" "" "# $tname" > "$filepath"
            end
            echo -n "$filepath" > /tmp/hx_note_path

          case project
            set -l tname (_titlecase $name)
            set -l filepath "$NOTES/projects/$tname.md"
            mkdir -p "$NOTES/projects"
            if not test -e "$filepath"
              set -l id (uuidgen)
              printf "%s\n" "---" "id: $id" "aliases:" "  - $tname" "tags: []" "---" "" "# $tname" "" "## Overview" "" "## Goals" "" "## Stakeholders" "" "## Key Decisions" "" "## Risks" "" "## Status Updates" > "$filepath"
            end
            echo -n "$filepath" > /tmp/hx_note_path

          case company
            set -l tname (_titlecase $name)
            set -l filepath "$NOTES/companies/$tname.md"
            mkdir -p "$NOTES/companies"
            if not test -e "$filepath"
              set -l id (uuidgen)
              printf "%s\n" "---" "id: $id" "aliases:" "  - $tname" "tags: []" "---" "" "# $tname" "" "## Overview" "" "## Leadership" "" "## Culture Signals" "" "## Tech Stack & Challenges" "" "## Role Details" "" "## Compensation" "" "## Concerns" "" "## Questions to Ask" "" "## Verdict" > "$filepath"
            end
            echo -n "$filepath" > /tmp/hx_note_path

          case decision
            set -l tname (_titlecase $name)
            set -l filepath "$NOTES/decisions/$tname.md"
            mkdir -p "$NOTES/decisions"
            if not test -e "$filepath"
              set -l id (uuidgen)
              printf "%s\n" "---" "id: $id" "aliases:" "  - $tname" "tags: []" "---" "" "# $tname" "" "## Problem Statement" "" "## Options" "" "### Option 1" "" "**Pros:**" "" "**Cons:**" "" "### Option 2" "" "**Pros:**" "" "**Cons:**" "" "## Recommendation" "" "## Tradeoffs" "" "## Decision" > "$filepath"
            end
            echo -n "$filepath" > /tmp/hx_note_path

          case incident
            set -l tname (_titlecase $name)
            set -l filepath "$NOTES/incidents/$tname.md"
            mkdir -p "$NOTES/incidents"
            if not test -e "$filepath"
              set -l id (uuidgen)
              set -l now (date +%H:%M)
              printf "%s\n" "---" "id: $id" "aliases:" "  - $tname" "tags: []" "---" "" "# $tname" "" "## Timeline" "" "- $now - Incident identified" "" "## Impact" "" "## Root Cause" "" "## Resolution" "" "## Action Items" "" "## Prevention" > "$filepath"
            end
            echo -n "$filepath" > /tmp/hx_note_path

          case '*'
            echo -n $input
            return 1
        end

        echo -n $input
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

        # _titlecase
        if test (_titlecase "john doe") = "John Doe"
          set pass (math $pass + 1); echo "  ✓ _titlecase basic"
        else
          set fail (math $fail + 1); echo "  ✗ _titlecase basic"
        end

        if test (_titlecase "JOHN DOE") = "John Doe"
          set pass (math $pass + 1); echo "  ✓ _titlecase uppercase input"
        else
          set fail (math $fail + 1); echo "  ✗ _titlecase uppercase input"
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
        if test -e "$tmpdir/people/Test Person.md"; and grep -q '^id:' "$tmpdir/people/Test Person.md"
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
}
