function notes-test --description="Run tests for notes system functions"
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
    if test (_slugify "hello world") = hello-world
        set pass (math $pass + 1)
        echo "  ✓ _slugify basic"
    else
        set fail (math $fail + 1)
        echo "  ✗ _slugify basic"
    end

    if test (_slugify "My Cool Project") = my-cool-project
        set pass (math $pass + 1)
        echo "  ✓ _slugify multi-word"
    else
        set fail (math $fail + 1)
        echo "  ✗ _slugify multi-word"
    end

    if test (_slugify "already-hyphenated") = already-hyphenated
        set pass (math $pass + 1)
        echo "  ✓ _slugify already-hyphenated"
    else
        set fail (math $fail + 1)
        echo "  ✗ _slugify already-hyphenated"
    end

    # _titlecase
    if test (_titlecase "john doe") = "John Doe"
        set pass (math $pass + 1)
        echo "  ✓ _titlecase basic"
    else
        set fail (math $fail + 1)
        echo "  ✗ _titlecase basic"
    end

    if test (_titlecase "JOHN DOE") = "John Doe"
        set pass (math $pass + 1)
        echo "  ✓ _titlecase uppercase input"
    else
        set fail (math $fail + 1)
        echo "  ✗ _titlecase uppercase input"
    end

    # _is_gnu_date — must agree with an INDEPENDENT probe (GNU date has
    # --version; BSD date doesn't). _is_gnu_date itself probes `date -d`, so
    # this cross-check can actually fail if the detection is wrong.
    set -l date_is_gnu false
    if date --version 2>/dev/null | string match -qr GNU
        set date_is_gnu true
    end
    if _is_gnu_date 2>/dev/null; and test "$date_is_gnu" = true
        set pass (math $pass + 1)
        echo "  ✓ _is_gnu_date agrees with date --version (GNU)"
    else if not _is_gnu_date 2>/dev/null; and test "$date_is_gnu" = false
        set pass (math $pass + 1)
        echo "  ✓ _is_gnu_date agrees with date --version (BSD)"
    else
        set fail (math $fail + 1)
        echo "  ✗ _is_gnu_date disagrees with the date --version probe"
    end

    # _require_notes
    if _require_notes >/dev/null 2>&1
        set pass (math $pass + 1)
        echo "  ✓ _require_notes with NOTES set"
    else
        set fail (math $fail + 1)
        echo "  ✗ _require_notes with NOTES set"
    end

    set -e NOTES
    if not _require_notes >/dev/null 2>&1
        set pass (math $pass + 1)
        echo "  ✓ _require_notes with NOTES unset"
    else
        set fail (math $fail + 1)
        echo "  ✗ _require_notes with NOTES unset"
    end
    set -gx NOTES "$tmpdir"

    # _require_notes_dir
    if _require_notes_dir >/dev/null 2>&1
        set pass (math $pass + 1)
        echo "  ✓ _require_notes_dir with valid dir"
    else
        set fail (math $fail + 1)
        echo "  ✗ _require_notes_dir with valid dir"
    end

    # _hx_toggle_task
    set -l checked (echo "- [ ] my task" | _hx_toggle_task)
    if test "$checked" = "- [x] my task @completed($today)"
        set pass (math $pass + 1)
        echo "  ✓ _hx_toggle_task check"
    else
        set fail (math $fail + 1)
        echo "  ✗ _hx_toggle_task check (got: $checked)"
    end

    set -l unchecked (echo "- [x] my task @completed($today)" | _hx_toggle_task)
    if test "$unchecked" = "- [ ] my task"
        set pass (math $pass + 1)
        echo "  ✓ _hx_toggle_task uncheck"
    else
        set fail (math $fail + 1)
        echo "  ✗ _hx_toggle_task uncheck (got: $unchecked)"
    end

    set -l passthrough (echo "regular line" | _hx_toggle_task)
    if test "$passthrough" = "regular line"
        set pass (math $pass + 1)
        echo "  ✓ _hx_toggle_task passthrough"
    else
        set fail (math $fail + 1)
        echo "  ✗ _hx_toggle_task passthrough (got: $passthrough)"
    end

    # ── Template Creation ──
    echo ""
    set_color --bold
    echo "Template Creation"
    set_color normal

    # _daily_create
    set -l dc_path (_daily_create 2>/dev/null)
    if test "$dc_path" = "$tmpdir/daily/$today.md"; and test -e "$dc_path"; and grep -q '^id:' "$dc_path"
        set pass (math $pass + 1)
        echo "  ✓ _daily_create creates today's note"
    else
        set fail (math $fail + 1)
        echo "  ✗ _daily_create creates today's note (got: $dc_path)"
    end

    echo SENTINEL-do-not-clobber >>"$dc_path"
    set -l dc_path2 (_daily_create 2>/dev/null)
    if test "$dc_path2" = "$dc_path"; and grep -q SENTINEL-do-not-clobber "$dc_path"
        set pass (math $pass + 1)
        echo "  ✓ _daily_create idempotent"
    else
        set fail (math $fail + 1)
        echo "  ✗ _daily_create idempotent"
    end

    set -e NOTES
    if not _daily_create >/dev/null 2>&1
        set pass (math $pass + 1)
        echo "  ✓ _daily_create fails with NOTES unset"
    else
        set fail (math $fail + 1)
        echo "  ✗ _daily_create fails with NOTES unset"
    end
    set -gx NOTES "$tmpdir"

    person "Test Person" >/dev/null 2>&1
    if test -e "$tmpdir/people/Test Person.md"; and grep -q '^id:' "$tmpdir/people/Test Person.md"
        set pass (math $pass + 1)
        echo "  ✓ person"
    else
        set fail (math $fail + 1)
        echo "  ✗ person"
    end

    project "Test Project" >/dev/null 2>&1
    if test -e "$tmpdir/projects/Test Project.md"; and grep -q '^id:' "$tmpdir/projects/Test Project.md"
        set pass (math $pass + 1)
        echo "  ✓ project"
    else
        set fail (math $fail + 1)
        echo "  ✗ project"
    end

    adr "Test ADR" >/dev/null 2>&1
    if test -e "$tmpdir/decisions/Test Adr.md"; and grep -q '^id:' "$tmpdir/decisions/Test Adr.md"
        set pass (math $pass + 1)
        echo "  ✓ adr"
    else
        set fail (math $fail + 1)
        echo "  ✗ adr"
    end

    decision "Test Decision" >/dev/null 2>&1
    if test -e "$tmpdir/decisions/Test Decision.md"; and grep -q '^id:' "$tmpdir/decisions/Test Decision.md"
        set pass (math $pass + 1)
        echo "  ✓ decision"
    else
        set fail (math $fail + 1)
        echo "  ✗ decision"
    end

    incident "Test Incident" >/dev/null 2>&1
    if test -e "$tmpdir/incidents/Test Incident.md"; and grep -q '^id:' "$tmpdir/incidents/Test Incident.md"
        set pass (math $pass + 1)
        echo "  ✓ incident"
    else
        set fail (math $fail + 1)
        echo "  ✗ incident"
    end

    company "Test Company" >/dev/null 2>&1
    if test -e "$tmpdir/companies/Test Company.md"; and grep -q '^id:' "$tmpdir/companies/Test Company.md"
        set pass (math $pass + 1)
        echo "  ✓ company"
    else
        set fail (math $fail + 1)
        echo "  ✗ company"
    end

    daily >/dev/null 2>&1
    if test -e "$tmpdir/daily/$today.md"; and grep -q '^id:' "$tmpdir/daily/$today.md"
        set pass (math $pass + 1)
        echo "  ✓ daily"
    else
        set fail (math $fail + 1)
        echo "  ✗ daily"
    end

    weekly >/dev/null 2>&1
    if test -e "$tmpdir/reviews/$today.md"; and grep -q '^id:' "$tmpdir/reviews/$today.md"
        set pass (math $pass + 1)
        echo "  ✓ weekly"
    else
        set fail (math $fail + 1)
        echo "  ✗ weekly"
    end

    set -l month (date +%Y-%m)
    monthly >/dev/null 2>&1
    if test -e "$tmpdir/monthly/$month.md"; and grep -q '^id:' "$tmpdir/monthly/$month.md"
        set pass (math $pass + 1)
        echo "  ✓ monthly"
    else
        set fail (math $fail + 1)
        echo "  ✗ monthly"
    end

    set -l year (date +%Y)
    quarterly Q1 $year >/dev/null 2>&1
    if test -e "$tmpdir/quarterly/$year-Q1.md"; and grep -q '^id:' "$tmpdir/quarterly/$year-Q1.md"
        set pass (math $pass + 1)
        echo "  ✓ quarterly"
    else
        set fail (math $fail + 1)
        echo "  ✗ quarterly"
    end

    # review weekly
    review weekly >/dev/null 2>&1
    set -l review_file (find "$tmpdir/reviews" -name 'week-*.md' 2>/dev/null | head -1)
    if test -n "$review_file"; and grep -q 'Completed Tasks' "$review_file"; and grep -q Overdue "$review_file"
        set pass (math $pass + 1)
        echo "  ✓ review weekly"
    else
        set fail (math $fail + 1)
        echo "  ✗ review weekly"
    end

    # ── Sync & Migration ──
    echo ""
    set_color --bold
    echo "Sync & Migration"
    set_color normal

    set -l _saved_notes $NOTES
    set -l _saved_cwd $PWD
    cd $tmpdir
    set -gx NOTES "$tmpdir/does-not-exist"
    if not notes-sync >/dev/null 2>&1
        set pass (math $pass + 1)
        echo "  ✓ notes-sync fails when NOTES dir missing"
    else
        set fail (math $fail + 1)
        echo "  ✗ notes-sync fails when NOTES dir missing"
    end
    set -gx NOTES "$_saved_notes"
    cd $_saved_cwd

    set -l sync_output (notes-sync 2>/dev/null)
    if string match -q '*not a jj repository*' -- "$sync_output"
        set pass (math $pass + 1)
        echo "  ✓ notes-sync handles non-jj dir"
    else
        set fail (math $fail + 1)
        echo "  ✗ notes-sync handles non-jj dir (got: $sync_output)"
    end

    mkdir -p "$tmpdir/migrate-test"
    echo "---
id: weekly-2024-01-01
tags: [test]
---
# Test" >"$tmpdir/migrate-test/test.md"
    migrate-ids >/dev/null 2>&1
    set -l new_id (awk '/^---$/{n++; next} n==1 && /^id:/{sub(/^id: */, ""); print; exit}' "$tmpdir/migrate-test/test.md")
    if string match -rq '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' -- "$new_id"
        set pass (math $pass + 1)
        echo "  ✓ migrate-ids replaces non-UUID ids"
    else
        set fail (math $fail + 1)
        echo "  ✗ migrate-ids replaces non-UUID ids (got: $new_id)"
    end

    set -l remote_dir "$tmpdir/remote.git"
    # -b main: don't depend on the runner's init.defaultBranch (a bare repo
    # otherwise defaults to master, which breaks jj's main tracking)
    git init --bare -q -b main "$remote_dir"
    set -l pushfail_dir "$tmpdir/pushfail"
    jj git init "$pushfail_dir" >/dev/null 2>&1
    jj -R "$pushfail_dir" git remote add origin "$remote_dir"
    echo seed >"$pushfail_dir/f.md"
    jj -R "$pushfail_dir" commit -m seed >/dev/null 2>&1
    jj -R "$pushfail_dir" bookmark create main -r @- >/dev/null 2>&1
    jj -R "$pushfail_dir" git push -b main >/dev/null 2>&1
    rm -rf "$remote_dir"
    echo more >>"$pushfail_dir/f.md"
    set -gx NOTES "$pushfail_dir"
    if not notes-sync >/dev/null 2>&1
        set pass (math $pass + 1)
        echo "  ✓ notes-sync fails when push fails"
    else
        set fail (math $fail + 1)
        echo "  ✗ notes-sync fails when push fails"
    end
    set -gx NOTES "$tmpdir"

    # notes-sync fetch + merge (rebase). Two clones of a bare remote diverge;
    # notes-sync must 3-way-merge non-overlapping edits and refuse to push a
    # true conflict.
    set -l mroot "$tmpdir/merge-test"
    mkdir -p "$mroot"
    set -l mremote "$mroot/remote.git"
    git init --bare -q -b main "$mremote"
    jj git clone "$mremote" "$mroot/A" >/dev/null 2>&1
    printf 'l1\nl2\nl3\n' >"$mroot/A/note.md"
    jj -R "$mroot/A" describe -m seed >/dev/null 2>&1
    jj -R "$mroot/A" bookmark create main -r @ >/dev/null 2>&1
    jj -R "$mroot/A" git push -b main >/dev/null 2>&1
    jj git clone "$mremote" "$mroot/B" >/dev/null 2>&1

    # Clean merge: B edits l3 and pushes; A edits l1, then syncs → both survive.
    printf 'l1\nl2\nB3\n' >"$mroot/B/note.md"
    jj -R "$mroot/B" describe -m b >/dev/null 2>&1
    jj -R "$mroot/B" bookmark move main --to @ >/dev/null 2>&1
    jj -R "$mroot/B" git push >/dev/null 2>&1
    printf 'A1\nl2\nl3\n' >"$mroot/A/note.md"
    set -gx NOTES "$mroot/A"
    notes-sync >/dev/null 2>&1
    set -l merge_rc $status
    set -l merged (cat "$mroot/A/note.md")
    if test $merge_rc -eq 0; and string match -q '*A1*' -- $merged; and string match -q '*B3*' -- $merged
        set pass (math $pass + 1)
        echo "  ✓ notes-sync merges non-overlapping remote+local edits"
    else
        set fail (math $fail + 1)
        echo "  ✗ notes-sync merges non-overlapping remote+local edits (rc=$merge_rc: $merged)"
    end

    # True conflict: both sides edit the same line differently → must NOT push.
    # Build B's next commit fresh on top of the current remote tip. (A `jj rebase`
    # of B's now-immutable, already-merged working copy is a no-op under jj's
    # fast-forward-only bookmark + immutability rules, so `jj new main@origin`.)
    jj -R "$mroot/B" git fetch >/dev/null 2>&1
    jj -R "$mroot/B" new 'main@origin' >/dev/null 2>&1
    printf 'A1\nB-l2\nB3\n' >"$mroot/B/note.md"
    jj -R "$mroot/B" describe -m bc >/dev/null 2>&1
    jj -R "$mroot/B" bookmark move main --to @ >/dev/null 2>&1
    jj -R "$mroot/B" git push >/dev/null 2>&1
    set -l remote_before (git --git-dir="$mremote" rev-parse refs/heads/main)
    printf 'A1\nA-l2\nB3\n' >"$mroot/A/note.md"
    notes-sync >/dev/null 2>&1
    set -l conf_rc $status
    set -l remote_after (git --git-dir="$mremote" rev-parse refs/heads/main)
    if test $conf_rc -ne 0; and test "$remote_before" = "$remote_after"
        set pass (math $pass + 1)
        echo "  ✓ notes-sync refuses to push a true conflict"
    else
        set fail (math $fail + 1)
        echo "  ✗ notes-sync refuses to push a true conflict (rc=$conf_rc)"
    end
    set -gx NOTES "$tmpdir"

    set -l _saved_tmux (set -q TMUX; and echo "$TMUX"; or echo "")
    set -gx TMUX test-guard
    set -gx NOTES "$tmpdir/missing-notes-dir"
    set -l nw_out (nw 2>&1)
    if string match -q '*does not exist*' -- "$nw_out"
        set pass (math $pass + 1)
        echo "  ✓ nw fails fast when NOTES dir missing"
    else
        set fail (math $fail + 1)
        echo "  ✗ nw fails fast when NOTES dir missing (got: $nw_out)"
    end
    set -gx NOTES "$tmpdir"
    if test -n "$_saved_tmux"
        set -gx TMUX "$_saved_tmux"
    else
        set -e TMUX
    end

    # ── _note_create ──
    echo ""
    set_color --bold
    echo "_note_create"
    set_color normal

    # Creates the file in the type's subdirectory and returns its path
    set -l nc_path (_note_create person "ada lovelace" 2>/dev/null)
    if test "$nc_path" = "$tmpdir/people/Ada Lovelace.md"; and test -e "$nc_path"
        set pass (math $pass + 1)
        echo "  ✓ _note_create person → people/ (titlecased, path returned)"
    else
        set fail (math $fail + 1)
        echo "  ✗ _note_create person → people/ (got: $nc_path)"
    end

    # Created note carries id: frontmatter (the invariant migrate-ids depends on)
    if string match -rq '^id: [0-9a-f]{8}-[0-9a-f]{4}-' < "$tmpdir/people/Ada Lovelace.md"
        set pass (math $pass + 1)
        echo "  ✓ _note_create emits uuid frontmatter"
    else
        set fail (math $fail + 1)
        echo "  ✗ _note_create emits uuid frontmatter"
    end

    # Each type routes to its own directory
    _note_create project "orbital mechanics" >/dev/null 2>&1
    _note_create company "analytical engines" >/dev/null 2>&1
    if test -e "$tmpdir/projects/Orbital Mechanics.md"; and test -e "$tmpdir/companies/Analytical Engines.md"
        set pass (math $pass + 1)
        echo "  ✓ _note_create routes project/company to their dirs"
    else
        set fail (math $fail + 1)
        echo "  ✗ _note_create routes project/company to their dirs"
    end

    # Unknown type fails and writes nothing
    set -l nc_bad (_note_create bogustype whatever 2>/dev/null)
    if test $status -ne 0; and test -z "$nc_bad"; and not test -e "$tmpdir/bogustype"
        set pass (math $pass + 1)
        echo "  ✓ _note_create rejects unknown type"
    else
        set fail (math $fail + 1)
        echo "  ✗ _note_create rejects unknown type"
    end

    # Idempotent: a second call must not clobber an edited note
    echo "SENTINEL-EDIT" >> "$tmpdir/people/Ada Lovelace.md"
    _note_create person "ada lovelace" >/dev/null 2>&1
    if grep -q SENTINEL-EDIT "$tmpdir/people/Ada Lovelace.md"
        set pass (math $pass + 1)
        echo "  ✓ _note_create is idempotent (no overwrite)"
    else
        set fail (math $fail + 1)
        echo "  ✗ _note_create is idempotent (no overwrite)"
    end

    # ── _hx_ensure_note ──
    echo ""
    set_color --bold
    echo "_hx_ensure_note"
    set_color normal

    # Call as a plain command with a redirected stdin (read -lz honors it) and
    # capture stdout to a file — must NOT wrap in (...) command substitution,
    # which does not propagate the stdin redirect into the read.
    printf '%s' '[[Grace Hopper]]' >"$tmpdir/hx_in.txt"

    _hx_ensure_note person <"$tmpdir/hx_in.txt" >"$tmpdir/hx_out.txt"
    set -l hx_status $status

    # Extracts the [[Name]], creates the note, echoes the selection back verbatim
    if test $hx_status -eq 0; and test (cat "$tmpdir/hx_out.txt") = "[[Grace Hopper]]"
        set pass (math $pass + 1)
        echo "  ✓ _hx_ensure_note passes input through unchanged"
    else
        set fail (math $fail + 1)
        echo "  ✗ _hx_ensure_note passes input through unchanged (got: "(cat "$tmpdir/hx_out.txt")")"
    end

    # Creates the note on disk at the deterministic path for the extracted name
    if test -e "$tmpdir/people/Grace Hopper.md"
        set pass (math $pass + 1)
        echo "  ✓ _hx_ensure_note creates the note on disk"
    else
        set fail (math $fail + 1)
        echo "  ✗ _hx_ensure_note creates the note on disk"
    end

    # Bare name (helix selects inside the brackets) works too
    printf '%s' 'Katherine Johnson' >"$tmpdir/hx_bare.txt"
    _hx_ensure_note person <"$tmpdir/hx_bare.txt" >/dev/null
    if test -e "$tmpdir/people/Katherine Johnson.md"
        set pass (math $pass + 1)
        echo "  ✓ _hx_ensure_note handles a bare (unbracketed) name"
    else
        set fail (math $fail + 1)
        echo "  ✗ _hx_ensure_note handles a bare (unbracketed) name"
    end

    # NOTES unset → return 1, selection echoed back unchanged, no note written
    set -e NOTES
    _hx_ensure_note person <"$tmpdir/hx_in.txt" >"$tmpdir/hx_unset.txt"
    set -l hx_unset_status $status
    set -gx NOTES "$tmpdir"
    if test $hx_unset_status -ne 0; and test (cat "$tmpdir/hx_unset.txt") = "[[Grace Hopper]]"
        set pass (math $pass + 1)
        echo "  ✓ _hx_ensure_note fails safely when NOTES unset"
    else
        set fail (math $fail + 1)
        echo "  ✗ _hx_ensure_note fails safely when NOTES unset"
    end

    # Empty selection → return 1 (nothing to name)
    printf '' >"$tmpdir/hx_empty.txt"
    _hx_ensure_note person <"$tmpdir/hx_empty.txt" >/dev/null
    if test $status -ne 0
        set pass (math $pass + 1)
        echo "  ✓ _hx_ensure_note fails on empty input"
    else
        set fail (math $fail + 1)
        echo "  ✗ _hx_ensure_note fails on empty input"
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
end
