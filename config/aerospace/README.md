# Aerospace Config

Home Manager links this directory to `~/.config/aerospace` via `home-manager/base.nix`. Tweak window manager settings here to affect every host; use the context modules if a change is work- or home-only.

## Keybindings

### Layout — `ctrl-alt` + the first letter of what you want

| Key | Does | Mnemonic |
|---|---|---|
| `ctrl-alt-t` | tiling layout (press again to flip horizontal/vertical) | **T**iles |
| `ctrl-alt-a` | accordion layout (press again to flip horizontal/vertical) | **A**ccordion |
| `ctrl-alt-b` | balance sizes | **B**alance |
| `ctrl-alt-j` | join with window to the right | **J**oin |
| `ctrl-alt-space` | toggle floating / tiling | it floats free |

The layout key picks the *mode*; pressing it a second time flips the
*orientation*. `ctrl-alt` is the modifier because macOS barely uses it and
tmux (`alt-space` prefix, `alt-hjkl`), zellij (`ctrl` mode switches,
`alt-hjkl`), and herdr (`ctrl-b` prefix) all stay clear of it.

### Focus and move

| Key | Does |
|---|---|
| `cmd-<arrow>` | focus that direction (wraps within the workspace) |
| `cmd-shift-<arrow>` | move the window that direction |
| `alt-tab` / `alt-shift-tab` | focus next / previous window |

### Workspaces

| Key | Does |
|---|---|
| `cmd-<1-7>` | switch to workspace N |
| `cmd-shift-<1-7>` | send window to workspace N, stay put |
| `cmd-shift-ctrl-<1-7>` | send window to workspace N and follow it |

Workspaces: 1 Code · 2 Mail · 3 IM · 4 Teams · 5 Web · 6 Docs · 7 misc.

Known collision, accepted on purpose: `cmd-shift-3/4/5` shadow the macOS
screenshot shortcuts, and `cmd-<1-7>` shadow tab switching in Ghostty and
browsers.

## Applying changes

`~/.config/aerospace` is a symlink into the Nix store, so editing this file
does nothing until you rebuild:

```bash
darwin-rebuild switch --flake .#<hostname>
aerospace reload-config
```
