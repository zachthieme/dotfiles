# Dotfiles for Multiple Machines

Automated dotfiles for macOS and Linux hosts (including Raspberry Pi), powered by Nix flakes. The repo layers system defaults, OS-specific settings, and context overlays (home/work) so each machine receives the right configuration with minimal duplication.

For contributor-specific technical details, see [Repository Guidelines](./CLAUDE.md).

## Features

- **Cross-platform**: macOS via nix-darwin, Linux via standalone Home Manager
- **Fish shell**: Primary shell with vi keybindings, custom functions, and abbreviations
- **Catppuccin theming**: Consistent mocha theme across terminal, editor, and tools
- **Notes system**: Plain-markdown notes with tmux workspace, task tracking, and jj sync
- **Helix editor**: Modal editor with LSP support for Go, Nix, Zig, C/C++, Bash, Markdown, and more
- **Modern CLI tools**: eza, bat, fzf, zoxide, ripgrep, fd, jujutsu, lazygit

## Quick Start

```bash
# Clone and run install script (auto-detects host)
./install.sh
```

The script will:

1. Install Nix (via Determinate Systems installer) if needed
2. Install Homebrew on macOS if needed
3. Apply the appropriate flake configuration
4. Configure shell PATH for Home Manager on Linux

## Repository Layout

```
system/              # Platform-specific system configs (darwin.nix for macOS)
config/              # Static dotfiles symlinked into the home directory
  aerospace/         # macOS tiling window manager
  borders/           # Window border styling
  jrnl/              # Journal CLI config
  moxide/            # Markdown-oxide LSP config (symlinked into the notes vault)
  terminfo/          # Terminal capabilities (ghostty)
docs/                # Plans and design notes
home-manager/        # Home Manager modules
  base.nix           # Shared user config (programs, dotfiles, env vars)
  programs/          # Per-program configs (fish, git, helix, etc.)
modules/             # Infrastructure
  lib.nix            # Shared helper functions
  hosts/             # Host definitions and detection
  darwin/            # macOS configuration builder
  home-manager/      # Linux configuration builder
overlays/            # Context-specific overrides
  context/           # home vs work differences
  os/                # OS-level settings (Homebrew, macOS defaults)
packages/            # Shared package profiles
flake.nix            # Entry point
install.sh           # Bootstrap script
```

## Supported Hosts

Hosts are defined in `modules/hosts/definitions.nix`. Current hosts include:

| Host                 | System         | Context | Profile |
| -------------------- | -------------- | ------- | ------- |
| cortex               | aarch64-darwin | home    | full    |
| malv2                | x86_64-darwin  | home    | full    |
| zthieme34911         | aarch64-darwin | work    | full    |
| prod, dev, util      | x86_64-linux   | home    | full    |
| claude               | x86_64-linux   | home    | full    |
| omarchy              | x86_64-linux   | home    | full    |
| pi5, pi-nomad1/2/3   | aarch64-linux  | home    | core    |

## Common Tasks

### Rebuild after edits

**macOS:**

```bash
darwin-rebuild switch --flake .#<hostname>
darwin-rebuild switch --flake .          # Uses detected hostname
```

**Linux:**

```bash
home-manager switch -b backup --flake .#<hostname>
```

### Add a new host

1. Add entry to `modules/hosts/definitions.nix`:
   ```nix
   "myhostname" = {
     system = "aarch64-darwin";  # or x86_64-darwin, aarch64-linux, x86_64-linux
     user = "myuser";
     isWork = false;
     packages = [ ];
   };
   ```
2. Ensure hostname matches the machine's actual hostname
3. Run `./install.sh`

### Add software

- **All machines**: Add to the appropriate tier in `packages/common.nix` (`corePackages`, `devPackages`, or `heavyPackages`)
- **One host**: Add to that host's `packages` list in `definitions.nix`
- **macOS Homebrew**: Add to `overlays/os/darwin.nix` or context modules in `overlays/context/system/`

### Add dotfiles for a tool

1. Create `config/<tool>/` with your config files
2. Add symlink in `home-manager/base.nix`:
   ```nix
   home.file.".config/<tool>".source = ../config/<tool>;
   ```

### Add a program module

For tools with Home Manager options:

1. Create `home-manager/programs/<tool>.nix`
2. Import in `home-manager/base.nix`

## Notes System

A plain-markdown notes system built around [pike](https://github.com/zachthieme/pike), [wen](https://github.com/zachthieme/wen), helix, fish functions, and zellij. Notes live in `~/CloudDocs/Notes` (set via `$NOTES`) and are synced with jujutsu.

The tools each handle a different part of the workflow:

- **Pike** extracts tasks from markdown files and displays them in a live dashboard with preconfigured views (priority, overdue, upcoming, delegated, etc.)
- **Wen** shows a terminal calendar with due dates from pike highlighted inline
- **Helix** provides keybindings for toggling task checkboxes and creating linked notes from selected text
- **Fish functions** create templated notes and handle search, sync, and workspace management
- **Tmux** ties everything into a multi-pane workspace via `nw` (a zellij variant is available as `nw-zellij`)

### Workspace

Run `nw` to open a tmux workspace with three windows:

| Window | Contents |
| --- | --- |
| **daily** | Pike priority view + wen calendar (top), daily note in editor + tick countdown (bottom) |
| **tasks** | Full pike dashboard with all configured views |
| **shell** | General-purpose shell |

On exit, `nw` commits and pushes all changes via `notes-sync` (`nwk` kills the session).

### Tasks

Tasks are plain markdown checkboxes annotated with `@tags` and `@due()` dates:

```markdown
- [ ] Implement feature @due(2026-03-15) @weekly
- [x] Fix bug @due(2026-02-28) @completed(2026-02-27)
```

Pike queries these across all notes. Views are configured in `home-manager/programs/pike.nix`:

| View | Query | Purpose |
| --- | --- | --- |
| Priority | `open and ((@weekly or @today) or (@due <= today))` | Tasks to focus on now |
| Overdue | `open and @due < today` | Past-due tasks |
| Next 3 Days | `open and @due >= today and @due <= today+3d` | Upcoming deadlines |
| Talk | `open and @talk` | Items to discuss with someone |
| Delegated | `open and @delegated` | Waiting on others |
| Horizon | `@risk or @horizon` | Longer-term concerns |

### Helix Integration

Keybindings for working with notes in helix (`home-manager/programs/helix.nix`):

| Binding | Action |
| --- | --- |
| `space x` | Toggle task completion — checks/unchecks the box and stamps `@completed(YYYY-MM-DD)` |
| `space t` | Toggle checkbox formatting on a line (list item ↔ task) |
| `space T` | Insert pike task list scoped to the current file |
| `space o p` | Create a person note from the `[[wikilink]]` under the cursor |
| `space o j` | Create a project note |
| `space o c` | Create a company note |
| `space o a` | Create an ADR |
| `space o d` | Create a decision document |
| `space o i` | Create an incident report |

Each `space o` binding is a single keyboard macro (helix does not allow macros inside command sequences), e.g. for projects:

```
"@mi[:pipe<space>_hx_ensure_note<space>project<ret>;"
```

The macro replays `mi[` to select the contents of the innermost `[...]` pair around the cursor, so the bindings work from anywhere inside a `[[wikilink]]` — no manual selection needed; with no surrounding brackets, the current selection is used instead. The selected text is then piped through `_hx_ensure_note`, which creates the note from a template if it doesn't exist and echoes the text back unchanged, leaving the buffer untouched. The trailing `;` collapses the selection.

### Note Templates

Fish functions create markdown files with YAML frontmatter (UUID id, aliases, tags) in organized subdirectories:

| Function | Directory | Purpose |
| --- | --- | --- |
| `daily` | `daily/` | Today's daily note (creates or opens existing) |
| `weekly` | `reviews/` | Weekly review (wins, challenges, priorities) |
| `monthly` | `monthly/` | Monthly review (highlights, completed, priorities) |
| `quarterly` | `quarterly/` | Quarterly review (goals, accomplishments, learnings) |
| `person <name>` | `people/` | Person profile |
| `project <name>` | `projects/` | Project with goals, stakeholders, decisions, risks |
| `company <name>` | `companies/` | Company research (leadership, culture, tech stack) |
| `adr <title>` | `decisions/` | Architecture decision record |
| `decision <title>` | `decisions/` | Decision document with options and tradeoffs |
| `incident <title>` | `incidents/` | Incident report with timeline and action items |
| `review [weekly\|monthly\|quarterly]` | `reviews/` | Review pre-filled with completed/overdue tasks for LLM analysis |

### Search and Navigation

| Command | Description |
| --- | --- |
| `notes` (or `n`) | Fuzzy-find notes with bat preview, or create a new note from the search query |
| `sn [-n]` | Full-text search inside notes with ripgrep, jump to matching line (`-n` disables preview) |
| `pike -q "query"` | One-shot task query to stdout (e.g. `pike -q "open and @talk"`) |

### Abbreviations

| Alias | Expands to | Description |
| ----- | --- | --- |
| `n` | `notes` | Fuzzy-find/create notes |
| `fw` | `pike -w Priority` | Priority tasks (weekly + today) |
| `fo` | `pike -w Overdue` | Overdue tasks |
| `fu` | `pike -w 'Next 3 Days'` | Upcoming deadlines |
| `td` | `pike --summary` | Task count summary |

### Syncing

`notes-sync` uses jujutsu to commit with a timestamp message and push to a remote. It checks for changes first to avoid empty commits. The `nw` workspace calls this automatically on exit.

## Fish Shell Functions

Other fish functions beyond the notes system:

| Function              | Description                        |
| --------------------- | ---------------------------------- |
| `logg`                | Interactive git log explorer       |
| `gff <file>`          | Git file history browser           |
| `fif`, `fifs`        | Find-in-files with fzf             |
| `k`                   | Interactive process killer         |
| `mkdd`                | Create directory with today's date |
| `nix-cleanup`         | Clean up Nix store                 |

Run `aliases` to see all abbreviations and functions in the shell.

## Validation

```bash
nix flake check                                    # Syntax and evaluation
darwin-rebuild switch --dry-run --flake .#host    # Preview macOS changes
home-manager switch --dry-run --flake .#host      # Preview Linux changes
```

## Troubleshooting

- **Rebuild fails**: Re-run with `--show-trace` for detailed errors
- **Fresh Linux install silent exit**: Ensure install.sh has the `set -e` fix (use explicit `if` in `source_nix_profile`)
- **Shell not fish after install**: Run the commands printed by install.sh to change default shell

## Key Design Principles

1. **Single source of truth**: Host metadata only in `definitions.nix`
2. **Layer separation**: System settings in `system/`, deltas in `overlays/`
3. **No duplication**: Shared logic in `modules/lib.nix`
4. **Declarative config**: Prefer Home Manager options over shell scripts
