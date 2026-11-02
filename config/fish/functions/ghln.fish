function ghln --description="Count open issues per numbered label (e.g. 1-needs-review) in the current gh repo"
    set -l labels (gh label list --limit 1000 --json name --jq '.[].name | select(test("^[0-9]+(-[A-Za-z0-9]+)+$"))' | sort -V)
    or return 1
    if test (count $labels) -eq 0
        echo "No numbered labels in this repo"
        return 0
    end
    ghlc $labels
end
