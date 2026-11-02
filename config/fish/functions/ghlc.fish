function ghlc --description="Count open issues per label in the current gh repo"
    set -l labels $argv
    if test (count $labels) -eq 0
        set labels ready-for-agent needs-triage pending-verify wayfinder:grilling
    end
    for label in $labels
        set -l n (gh issue list --state open --label $label --limit 1000 --json number --jq length)
        or return 1
        printf "%-20s %s\n" $label $n
    end
end
