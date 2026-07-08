# Daily-Note Rollover and Periodic Sync

**Date:** 2026-07-08
**Status:** Approved

## Problem

The `nw` notes tmux session stays open for days at a time. The daily window
runs `daily; notes-sync` once at session creation, which means:

1. Helix stays open on the note for the day the session was created; new
   days require manually creating and opening today's note.
2. `notes-sync` only runs when Helix or tmux exits, so notes can go
   unsynced (uncommitted, unpushed) for days.

## Solution Overview

Two independent changes:

1. A Helix keybinding (`space o t`) that creates today's daily note if
   missing and opens it — usable at any time from inside the long-running
   Helix session.
2. The daily window's layout-filler pane (currently `cat`) becomes an
   hourly `notes-sync` loop, so syncing happens for as long as the notes
   session is open.

## Design

### 1. Fish refactor: `_daily_create` (home-manager/programs/fish/notes.nix)

New function `_daily_create`:

- Creates `$NOTES/daily/YYYY-MM-DD.md` from the existing daily template
  (UUID `id`, formatted-date alias, `tags: []`, `# <date>` header,
  `## Meetings`, `## Notes`) if the file does not exist.
- Prints the file path to stdout; "Created:" message goes to stderr,
  matching `_note_create`'s convention.
- Returns non-zero with no stdout if `NOTES` is unset or empty.

`daily` becomes a thin wrapper: `_require_notes`, call `_daily_create`,
`cd $NOTES`, open `$EDITOR` on the path, `cd` back. The template lives in
exactly one place.

### 2. Helix binding: `space o t` (home-manager/programs/helix.nix)

Added to `sharedBinds` (normal + select mode):

```nix
space.o.t = [":open %sh{_daily_create}"];
```

Helix's `editor.shell` is `fish -lc`, so `%sh{}` invokes the fish function
directly. This is a plain command sequence — no macro — so it does not hit
helix's "macros may not be used in command sequences" restriction.

Failure mode: if `NOTES` is unset, `_daily_create` prints nothing and
`:open` shows an error in the status line. No buffer is harmed.

### 3. Sync pane (home-manager/programs/fish/notes.nix, `nw`)

The daily window's spacer pane (below tick, currently running `cat` purely
for layout) instead runs:

```fish
while true
  notes-sync >/dev/null 2>&1
  echo "synced "(date +%H:%M)
  sleep 3600
end
```

- Syncs once at session start, then hourly.
- Prints one timestamped line per pass for visible liveness.
- `notes-sync` already no-ops when there are no changes and handles
  non-repo directories, so the loop adds no failure modes.
- Lives and dies with the tmux session; nothing runs outside it.

The zellij variant (`nw-zellij`) is unchanged — it uses a static layout
file and is no longer the primary workspace.

## Testing

- `notes-test` gains `_daily_create` cases: file created with `id:`
  frontmatter, prints the path, idempotent (second call returns the same
  path without rewriting), fails cleanly with `NOTES` unset.
- End-to-end: after `home-manager switch`, drive Helix in a pty with a
  scratch `NOTES` — press `space o t`, verify today's note exists and the
  template is correct.
- Manual: `nwk`, rerun `nw`, confirm the sync pane shows a "synced HH:MM"
  line and `jj log` in the notes repo shows an auto-save commit when
  changes exist.

## Out of Scope

- Midnight auto-rollover of the editor buffer (rejected: disruptive,
  keybinding covers the need).
- markdown-oxide's native daily-note jump (rejected: second template that
  has already drifted from the fish one; requires a markdown buffer with
  the LSP running).
- Syncing outside the notes session via systemd/launchd timers (rejected:
  all note edits happen inside the workspace).
