# Dotfiles for Multiple Machines

Automated dotfiles for macOS and Linux hosts (including Raspberry Pi), powered by Nix flakes. The repo layers system defaults, OS-specific settings, and context overlays (home/work) so each machine receives the right configuration with minimal duplication.

For contributor-specific technical details, see [Repository Guidelines](./CLAUDE.md).

## Features

- **Cross-platform**: macOS via nix-darwin, Linux via standalone Home Manager
- **Fish shell**: Primary shell with vi keybindings, custom functions, and abbreviations
- **Catppuccin theming**: Consistent mocha theme across terminal, editor, and tools
- **Notes system**: Plain-markdown notes with zellij workspace, task tracking, and jj sync
- **Helix editor**: Modal editor with LSP support for Go, Rust, Nix, TypeScript, and more
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
config/              # Static dotfiles symlinked to ~/.config
  aerospace/         # macOS tiling window manager
  borders/           # Window border styling
  jrnl/              # Journal CLI config
  moxide/            # Markdown-oxide LSP config (for Obsidian)
  ripgrep/           # Ripgrep config
  terminfo/          # Terminal capabilities (ghostty)
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

| Host | System | Context |
|------|--------|---------|
| cortex | aarch64-darwin | home |
| malv2 | x86_64-darwin | home |
| zthieme34911 | aarch64-darwin | work |
| srv722852 | x86_64-linux | home |
| omarchy | x86_64-linux | home |
| pi5 | aarch64-linux | home |
| pi-nomad1/2/3 | aarch64-linux | home |

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

- **All machines**: Add to `profiles.basePackages` in `packages/common.nix`
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

A plain-markdown notes system built on fish functions, helix, and zellij. Notes live in `~/CloudDocs/Notes` (set via `$NOTES`) and are synced with jujutsu.

### Workspace

Run `nw` to open a zellij workspace with four tabs:

| Tab | Contents |
|-----|----------|
| **notes** | Weekly/today tasks at top, daily note below (auto-syncs on open) |
| **search** | Full-text search across all notes (`sn`) |
| **overdue** | Tasks with past due dates |
| **shell** | General-purpose shell |

On exit, `nw` commits and pushes all changes via `notes-sync`.

### Note Templates

Each function creates a markdown file with YAML frontmatter (UUID id, aliases, tags) in its own subdirectory:

| Function | Directory | Purpose |
|----------|-----------|---------|
| `daily` | `daily/` | Today's daily note (creates or opens existing) |
| `weekly` | `weekly/` | Weekly review (wins, challenges, priorities) |
| `quarterly` | `quarterly/` | Quarterly review (goals, accomplishments, learnings) |
| `monthly` | `monthly/` | Monthly review (highlights, completed, priorities) |
| `person <name>` | `people/` | Person profile with contact info and notes |
| `project <name>` | `projects/` | Project with goals, stakeholders, decisions, risks |
| `company <name>` | `companies/` | Company research (leadership, culture, tech stack) |
| `adr <title>` | `adrs/` | Architecture decision record |
| `decision <title>` | `decisions/` | Decision document with options and tradeoffs |
| `incident <title>` | `incidents/` | Incident report with timeline and action items |

### Tasks

Tasks use markdown checkboxes with metadata annotations:

```markdown
- [ ] Implement feature @due(2026-03-15) @weekly
- [x] Fix bug @due(2026-02-28) @completed(2026-02-27)
```

| Function | Description |
|----------|-------------|
| `ft [tag]` | Find unchecked tasks, optionally filtered by tag pattern |
| `overdue` | Find unchecked tasks with `@due()` dates in the past |
| `done [days]` | Find completed tasks from last N days (default: 7) |
| `upcoming [days]` | Find tasks due within N days (default: 7) |
| `ts` | Show task summary dashboard (open, overdue, due/completed this week) |
| `review [week\|month]` | Create review note pre-filled with completed tasks |
| `notes` | Fuzzy-find notes or create a new one from the search query |
| `sn [-n]` | Full-text search inside notes with preview (`-n` disables preview) |
| `notes-sync` | Commit and push notes via jujutsu |

**Helix keybindings** for editing tasks:
- `space x` - Toggle task completion (adds/removes `@completed(date)`)
- `space t` - Toggle checkbox syntax on a line

### Abbreviations

| Alias | Expands to |
|-------|------------|
| `n` | `notes` |
| `fw` | `ft '@weekly\|@today'` |
| `fo` | `overdue` |
| `fc` | `done` |
| `fu` | `upcoming` |

### Syncing

`notes-sync` uses jujutsu to commit with a timestamp message and push to a remote. It checks for changes first to avoid empty commits. The `nw` workspace calls this automatically on exit.

## Fish Shell Functions

Other fish functions beyond the notes system:

| Function | Description |
|----------|-------------|
| `logg` | Interactive git log explorer |
| `gff <file>` | Git file history browser |
| `fif`, `fifs`, `fifc` | Find-in-files with fzf |
| `k` | Interactive process killer |
| `mkdd` | Create directory with today's date |
| `nix-cleanup` | Clean up Nix store |

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
