# Dotfiles for Multiple Machines

Automated dotfiles for multiple macOS and Linux hosts, powered by Nix flakes. The repo layers system defaults, architecture tweaks, and context-specific overrides so each machine receives the right mix with minimal duplication. For contributor-specific details, see [Repository Guidelines](./AGENTS.md).

## Why This Exists
- Single source of truth for workstation setup across personal and work machines.
- Repeatable, idempotent provisioning through `nix-darwin`, Home Manager, and overlays.
- Separation of base, architecture, context, and host layers to keep overrides tight and auditable.

## Repository Layout
```
base/                # Shared nix-darwin modules
config/              # Dotfiles grouped by application
home-manager/        # Home Manager base modules
modules/             # Host definitions and builders used by flake.nix
overlays/            # System + user overlays
  arch/              # Architecture-specific settings
  context/
    home-manager/    # Context-specific Home Manager modules
    system/          # Context-specific system modules
  os/                # OS-level tweaks (e.g., macOS defaults, Homebrew)
packages/            # Named package profiles
flake.nix            # Entry point wiring modules together
install.sh           # Bootstrap script for new machines
```

## Rules of the Road
- Treat `flake.nix` as the orchestration layer and keep host metadata in `modules/hosts/definitions.nix`.
- Keep shared logic in `base/` and `home-manager/base.nix`; put context deltas under `overlays/context/system/` (system) and `overlays/context/home-manager/` (user). The Home Manager base is a module, so it picks up `home.username`/`home.homeDirectory` from the host wiring automatically.
- Declare usernames (and other per-host facts) only in `modules/hosts/definitions.nix`. Downstream modules consume `config.local.username` or `config.home.username`; avoid re-stating literals in overlays.
- Prefer host-specific packages via the `hosts.<name>.packages` list in `modules/hosts/definitions.nix` rather than sprinkling conditionals inside modules.
- Run `nix flake check` before every commit; capture dry-run outputs (`darwin-rebuild switch --dry-run`, `home-manager switch --dry-run`) when opening a PR.
- Document significant changes in `AGENTS.md` to help other contributors stay aligned.

## Common Tasks
- **Bootstrap a machine:** `./install.sh` (detects host, installs prerequisites, applies correct flake).
- **Rebuild after edits:**  
  macOS: `darwin-rebuild switch --flake .#<hostname>`  
  Linux: `home-manager switch --flake .#srv722852`
- **Add a new host:** Extend `modules/hosts/definitions.nix` with a new entry, setting `system`, `user`, `isWork`, and optional `packages`. Pick the host key to match the machine’s hostname.
- **Add software for one machine:** Add a package to that host’s `packages` list in `modules/hosts/definitions.nix`. Use `pkgs.homebrewPackages.<formula>` when the app is a Homebrew formula.
- **Share dotfiles or app configs:** Place files under `config/<tool>/`; wire them in via `home-manager/base.nix` (shared) or the context modules in `overlays/context/home-manager/`.
- **Create new overlays:** Add a module under `overlays/<dimension>/` and wire it into the appropriate builder in `modules/darwin/mk-config.nix` or `modules/home-manager/mk-config.nix`.

## Validation & Troubleshooting
- Use `nix flake check` to catch syntax and evaluation regressions.
- If a rebuild fails, re-run with `--show-trace` for detailed Nix diagnostics.
- When a module introduces side effects, wrap them in `lib.mkIf` guards so they only run on the intended systems.

## Future Opportunities
- **Add CI validation:** Wire `nix flake check` (and key dry-run commands) into GitHub Actions so regressions surface before merges.
- **Harden host packages:** Export named package groups per context (e.g., `profiles/workstation`) and re-use them across system and Home Manager layers to avoid duplication.
- **Track config ownership:** Augment the new `config/*/README.md` stubs with maintainer notes or audit cadence once you learn which tools churn most.
