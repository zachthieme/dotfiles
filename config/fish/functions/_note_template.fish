function _note_template --description="Print note content (frontmatter + body) for a type. Usage: _note_template <type> <name>"
    set -l type $argv[1]
    set -l name $argv[2..]
    set -l id (uuidgen)
    printf "%s\n" --- "id: $id" "aliases:" "  - $name" "tags: []" --- "" "# $name"

    switch $type
        case person
            # header only
        case project
            printf "%s\n" "" "## Overview" "" "## Goals" "" "## Stakeholders" "" "## Key Decisions" "" "## Risks" "" "## Status Updates"
        case company
            printf "%s\n" "" "## Overview" "" "## Leadership" "" "## Culture Signals" "" "## Tech Stack & Challenges" "" "## Role Details" "" "## Compensation" "" "## Concerns" "" "## Questions to Ask" "" "## Verdict"
        case adr
            printf "%s\n" "" "## Status" "" Proposed "" "## Context" "" "## Options Considered" "" "### Option 1" "" "### Option 2" "" "## Decision" "" "## Consequences"
        case decision
            printf "%s\n" "" "## Problem Statement" "" "## Options" "" "### Option 1" "" "**Pros:**" "" "**Cons:**" "" "### Option 2" "" "**Pros:**" "" "**Cons:**" "" "## Recommendation" "" "## Tradeoffs" "" "## Decision"
        case incident
            set -l now (date +%H:%M)
            printf "%s\n" "" "## Timeline" "" "- $now - Incident identified" "" "## Impact" "" "## Root Cause" "" "## Resolution" "" "## Action Items" "" "## Prevention"
    end
end
