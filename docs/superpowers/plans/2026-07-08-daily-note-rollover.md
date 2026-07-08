# Daily-Note Rollover and Periodic Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a long-running notes tmux session roll over to new days — a Helix keybinding (`space o t`) creates/opens today's daily note, and the daily window's spacer pane syncs notes hourly.

**Architecture:** Extract the note-creation half of the fish `daily` function into `_daily_create` (prints the path, no editor) so both `daily` and a new Helix `:open %sh{_daily_create}` binding share one template. Replace the layout-filler `cat` pane in `nw` with an hourly `notes-sync` loop.

**Tech Stack:** Nix (Home Manager), fish functions, Helix keybindings, tmux. VCS is jujutsu (`jj`), NOT git. Rebuild command on this machine: `home-manager switch --flake /home/zach/code/dotfiles#claude`.

**Spec:** `docs/superpowers/specs/2026-07-08-daily-note-rollover-design.md`

**Important repo conventions:**
- All fish functions are defined declaratively in `.nix` files; they only take effect after `home-manager switch`.
- Tests live in the `notes-test` fish function (`home-manager/programs/fish/notes.nix`) and run against the *installed* functions — so the red/green cycle is: edit nix → rebuild → run `fish -c notes-test`.
- Commit with `jj commit -m "..."`, then `jj bookmark move main --to @-` and `jj git push`.

---

### Task 1: `_daily_create` fish function + `daily` refactor

**Files:**
- Modify: `home-manager/programs/fish/notes.nix` (the `daily` function ~line 221, the `notes-test` function ~line 751)

- [ ] **Step 1: Add failing tests to `notes-test`**

In `home-manager/programs/fish/notes.nix`, inside the `notes-test` body, find the `# ── Template Creation ──` section. Immediately BEFORE the line `person "Test Person" >/dev/null 2>&1`, add:

```fish
        # _daily_create
        set -l dc_path (_daily_create 2>/dev/null)
        if test "$dc_path" = "$tmpdir/daily/$today.md"; and test -e "$dc_path"; and grep -q '^id:' "$dc_path"
          set pass (math $pass + 1); echo "  ✓ _daily_create creates today's note"
        else
          set fail (math $fail + 1); echo "  ✗ _daily_create creates today's note (got: $dc_path)"
        end

        set -l dc_mtime (stat -c %Y "$dc_path" 2>/dev/null; or stat -f %m "$dc_path")
        set -l dc_path2 (_daily_create 2>/dev/null)
        set -l dc_mtime2 (stat -c %Y "$dc_path" 2>/dev/null; or stat -f %m "$dc_path")
        if test "$dc_path2" = "$dc_path"; and test "$dc_mtime2" = "$dc_mtime"
          set pass (math $pass + 1); echo "  ✓ _daily_create idempotent"
        else
          set fail (math $fail + 1); echo "  ✗ _daily_create idempotent"
        end

        set -e NOTES
        if not _daily_create >/dev/null 2>&1
          set pass (math $pass + 1); echo "  ✓ _daily_create fails with NOTES unset"
        else
          set fail (math $fail + 1); echo "  ✗ _daily_create fails with NOTES unset"
        end
        set -gx NOTES "$tmpdir"
```

Note: the `notes-test` body is a Nix `''...''` string with 8-space base indentation for fish code — match the indentation of the surrounding test blocks exactly.

- [ ] **Step 2: Rebuild and run tests to verify they fail**

Run:
```bash
home-manager switch --flake /home/zach/code/dotfiles#claude
fish -c notes-test
```
Expected: the three new `_daily_create` tests FAIL (the function does not exist yet; `(_daily_create ...)` produces an "Unknown command" error and empty output). All pre-existing tests still pass.

- [ ] **Step 3: Add `_daily_create` and refactor `daily`**

In `home-manager/programs/fish/notes.nix`, add a new function entry directly above the existing `daily` entry:

```nix
    _daily_create = {
      description = "Create today's daily note from template if missing; prints its path";
      body = ''
        if not set -q NOTES; or test -z "$NOTES"
          return 1
        end

        set -l today (date +%Y-%m-%d)
        set -l formatted (date +"%A %B %-d, %Y")
        set -l dir "$NOTES/daily"
        set -l filepath "$dir/$today.md"
        mkdir -p "$dir"

        if not test -e "$filepath"
          set -l id (uuidgen)
          printf "%s\n" "---" "id: $id" "aliases:" "  - $formatted" "tags: []" "---" "" "# $formatted" "" "## Meetings" "" "## Notes" > "$filepath"
          echo "Created: $filepath" >&2
        end

        echo -n "$filepath"
      '';
    };
```

Then REPLACE the entire existing `daily` entry (the one with the inline heredoc-style template) with:

```nix
    daily = {
      description = "Create or open today's daily note in daily/";
      body = ''
        _require_notes; or return 1

        set -l filepath (_daily_create)
        or return 1

        set -l prev_dir $PWD
        cd $NOTES
        $EDITOR "$filepath"
        cd $prev_dir
      '';
    };
```

The template content is identical to what `daily` produced before (UUID `id`, formatted-date alias, `tags: []`, `# <date>`, `## Meetings`, `## Notes`), so the existing `daily` test in `notes-test` keeps passing.

- [ ] **Step 4: Rebuild and run tests to verify they pass**

Run:
```bash
home-manager switch --flake /home/zach/code/dotfiles#claude
fish -c notes-test
```
Expected: `All N tests passed.` (previous count + 3 new tests, zero failures).

- [ ] **Step 5: Commit**

```bash
cd /home/zach/code/dotfiles
nix fmt
jj commit -m "notes: extract _daily_create from daily for reuse"
jj bookmark move main --to @-
jj git push
```

---

### Task 2: Helix binding `space o t`

**Files:**
- Modify: `home-manager/programs/helix.nix` (the `space.o` attrset in `sharedBinds`, ~line 12)

- [ ] **Step 1: Add the binding**

In `home-manager/programs/helix.nix`, the `space.o` attrset currently contains only macro-string bindings (`p = noteBind "person";` etc.). Add one line:

```nix
    space.o = {
      p = noteBind "person";
      j = noteBind "project";
      a = noteBind "adr";
      c = noteBind "company";
      d = noteBind "decision";
      i = noteBind "incident";
      t = [":open %sh{_daily_create}"];
    };
```

This is a plain command sequence (no `@` macro), so helix's "macro keybindings may not be used in command sequences" restriction does not apply.

- [ ] **Step 2: Rebuild and verify deployed config**

Run:
```bash
home-manager switch --flake /home/zach/code/dotfiles#claude
grep -A8 'space.o\]' ~/.config/helix/config.toml | grep 't = '
```
Expected: `t = [":open %sh{_daily_create}"]` under both `[keys.normal.space.o]` and `[keys.select.space.o]`.

- [ ] **Step 3: Verify helix config parses (pty launch)**

Run:
```bash
SCRATCH=/tmp/claude-1001/-home-zach-code-dotfiles/89912cd0-d879-41a0-b8cd-2c996a023cbd/scratchpad
printf ':q!\r' | timeout 10 script -qec "hx $SCRATCH/parse-test.md" /dev/null 2>&1 | grep -a -i "bad config\|parse error"; echo "scan done"
```
Expected: only `scan done` (no "Bad config" output).

- [ ] **Step 4: End-to-end test via pty**

Run:
```bash
SCRATCH=/tmp/claude-1001/-home-zach-code-dotfiles/89912cd0-d879-41a0-b8cd-2c996a023cbd/scratchpad
TMPN=$(mktemp -d -p $SCRATCH)
echo "scratch buffer" > "$TMPN/x.md"
(sleep 2; printf ' ot'; sleep 3; printf ':q!\r') | NOTES="$TMPN" timeout 20 script -qec "hx $TMPN/x.md" /dev/null >/dev/null 2>&1
ls "$TMPN/daily/" && head -6 "$TMPN/daily/"*.md
rm -rf "$TMPN"
```
Expected: `ls` shows `<today's date>.md` (e.g. `2026-07-08.md`) and the head shows `---`, `id: <uuid>`, `aliases:` frontmatter.

- [ ] **Step 5: Commit**

```bash
cd /home/zach/code/dotfiles
jj commit -m "helix: space o t opens today's daily note"
jj bookmark move main --to @-
jj git push
```

---

### Task 3: Hourly sync pane in `nw`

**Files:**
- Modify: `home-manager/programs/fish/notes.nix` (the `nw` function body, the spacer-pane line)

- [ ] **Step 1: Replace the spacer pane command**

In the `nw` function body, find:

```fish
tmux split-window -v -t $tick_pane -c $notes_dir "cat"
```

Replace with:

```fish
tmux split-window -v -t $tick_pane -c $notes_dir "fish -c 'while true; notes-sync >/dev/null 2>&1; echo synced (date +%H:%M); sleep 3600; end'"
```

Quoting notes: the outer `"..."` is fish (inside the `nw` function) — `$tick_pane`/`$notes_dir` interpolate, `(` does NOT command-substitute inside double quotes in fish, so the inner `(date +%H:%M)` passes through literally. tmux runs the string via `sh -c`, which launches `fish -c '...'`; only THAT fish evaluates the loop and the `(date ...)` substitution each hour.

Also update the pane-layout comment above the split-row diagram in `nw`: change `spacer (5)` to `sync (5)` in both places it appears (the row-major comment block).

- [ ] **Step 2: Rebuild**

Run:
```bash
home-manager switch --flake /home/zach/code/dotfiles#claude
```
Expected: activation completes with no errors.

- [ ] **Step 3: Verify the sync pane comes up (scripted tmux check)**

Run (uses a temp NOTES so no real notes are touched; requires no existing `notes` tmux session):
```bash
SCRATCH=/tmp/claude-1001/-home-zach-code-dotfiles/89912cd0-d879-41a0-b8cd-2c996a023cbd/scratchpad
TMPN=$(mktemp -d -p $SCRATCH)
tmux kill-session -t notes 2>/dev/null
(NOTES="$TMPN" EDITOR=true timeout 20 script -qec "fish -c nw" /dev/null >/dev/null 2>&1 &)
sleep 8
tmux list-panes -t notes:daily -F '#{pane_id}' | while read p; do tmux capture-pane -t "$p" -p; done | grep -a "synced"
tmux kill-session -t notes 2>/dev/null
rm -rf "$TMPN"
```
Expected: a line like `synced 09:41`. (pike/wen/tick panes may show errors in the temp dir — irrelevant to this check.)

- [ ] **Step 4: Commit**

```bash
cd /home/zach/code/dotfiles
jj commit -m "nw: replace spacer pane with hourly notes-sync loop"
jj bookmark move main --to @-
jj git push
```

---

### Task 4: README updates

**Files:**
- Modify: `README.md` (Helix Integration table; Workspace section)

- [ ] **Step 1: Add the binding to the Helix Integration table**

In `README.md`, in the Helix Integration table, add after the `space o i` row:

```markdown
| `space o t` | Create or open today's daily note |
```

- [ ] **Step 2: Document the sync pane in the Workspace section**

Change the sentence:

```markdown
On exit, `nw` commits and pushes all changes via `notes-sync` (`nwk` kills the session).
```

to:

```markdown
A small pane in the daily window runs `notes-sync` hourly while the session is open, and `nw` runs a final sync on exit (`nwk` kills the session).
```

- [ ] **Step 3: Commit**

```bash
cd /home/zach/code/dotfiles
jj commit -m "readme: document space o t binding and hourly sync pane"
jj bookmark move main --to @-
jj git push
```
