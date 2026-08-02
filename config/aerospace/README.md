# Aerospace Config

Home Manager links this directory to `~/.config/aerospace` via `home-manager/base.nix`. Tweak window manager settings here to affect every host; use the context modules if a change is work- or home-only.

## Keybindings

Two rules cover almost everything:

1. **More modifiers = further out.** Bare `hjkl` moves the cursor in helix,
   `alt-hjkl` moves between tmux panes, `ctrl-alt-hjkl` moves between windows.
2. **Adding shift moves the thing instead of moving you.**

### Focus and move — `ctrl-alt` + `hjkl`

| Key | Does |
|---|---|
| `ctrl-alt-h/j/k/l` | focus left / down / up / right (wraps within the workspace) |
| `ctrl-alt-shift-h/j/k/l` | move the window left / down / up / right |

### Layout — `ctrl-alt` + the first letter of what you want

| Key | Does | Mnemonic |
|---|---|---|
| `ctrl-alt-t` | tiling layout (press again to flip horizontal/vertical) | **T**iles |
| `ctrl-alt-a` | accordion layout (press again to flip horizontal/vertical) | **A**ccordion |
| `ctrl-alt-b` | balance sizes | **B**alance |
| `ctrl-alt-space` | toggle floating / tiling | it floats free |

The layout key picks the *mode*; pressing it a second time flips the
*orientation*. To move between windows stacked in an accordion, use the focus
keys above — `ctrl-alt-h/l` in a horizontal accordion, `ctrl-alt-j/k` in a
vertical one.

### Workspaces

| Key | Does |
|---|---|
| `cmd-<1-7>` | switch to workspace N |
| `cmd-shift-<1-7>` | send window to workspace N, stay put |
| `cmd-shift-ctrl-<1-7>` | send window to workspace N and follow it |
| `ctrl-alt-0` | reshelve every window onto its assigned workspace (`aero-tidy`) |

Workspaces: 1 Code · 2 Mail · 3 IM · 4 Teams · 5 Web · 6 Docs · 7 misc.

Known collision, accepted on purpose: `cmd-shift-3/4/5` shadow the macOS
screenshot shortcuts.

## Why `ctrl-alt`

It's the one modifier macOS barely touches that is also clear of everything
running inside the terminal — tmux takes `alt-space` as its prefix plus
`alt-hjkl` and `alt-1..9`, and herdr prefixes on `ctrl-b`. Neither binds
`ctrl-alt`, so the window layer never fights the pane layer.

## Applying changes

`~/.config/aerospace` is a symlink into the Nix store, so editing this file
does nothing until you rebuild:

```bash
darwin-rebuild switch --flake .#<hostname>
aerospace reload-config
```
