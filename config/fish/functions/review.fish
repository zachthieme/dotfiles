function review --description="Generate a review (weekly, monthly, quarterly) pre-filled with tasks for LLM analysis"
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
                set q_start_month 7
                set q_end_month 9
                set q_year $year
                set q_label Q4
            else if test $month -ge 7
                # In Q4 (Jul-Sep): last full = Q3 Apr-Jun same year
                set q_start_month 4
                set q_end_month 6
                set q_year $year
                set q_label Q3
            else if test $month -ge 4
                # In Q3 (Apr-Jun): last full = Q2 Jan-Mar same year
                set q_start_month 1
                set q_end_month 3
                set q_year $year
                set q_label Q2
            else
                # In Q2 (Jan-Mar): last full = Q1 Oct-Dec previous year
                set q_start_month 10
                set q_end_month 12
                set q_year (math $year - 1)
                set q_label Q1
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
" >"$filepath"

    if test (count $completed_tasks) -gt 0
        printf '%s\n' $completed_tasks >>"$filepath"
    else
        echo "_No completed tasks._" >>"$filepath"
    end

    printf "\n## Overdue\n\n" >>"$filepath"

    if test (count $overdue_tasks) -gt 0
        printf '%s\n' $overdue_tasks >>"$filepath"
    else
        echo "_No overdue tasks._" >>"$filepath"
    end

    printf "\n## %s Tasks\n\n" "$tag_label" >>"$filepath"

    if test (count $tagged_tasks) -gt 0
        printf '%s\n' $tagged_tasks >>"$filepath"
    else
        echo "_No tagged tasks._" >>"$filepath"
    end

    printf "\n## Reflections\n\n## Key Themes\n\n## Next Period Priorities\n\n" >>"$filepath"
    printf "***\n\n" >>"$filepath"
    echo "*Analyze this $period review and identify: key accomplishments and their impact, patterns in completed vs overdue work, recurring themes, suggested priorities for next period, and areas of concern.*" >>"$filepath"

    echo "Created: $filepath"

    set -l prev_dir $PWD
    cd $NOTES
    $EDITOR "$filepath"
    cd $prev_dir
end
