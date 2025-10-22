# Repository Guidelines

## Project Structure & Module Organization
This repository drives machine-specific dotfiles through Nix flakes. Host metadata lives in `modules/hosts/definitions.nix`, and `flake.nix` composes the right architecture/context overlays before exporting `darwinConfigurations` and `homeConfigurations`. Shared system defaults live in `base/default.nix`, while user-level layers originate from `home-manager/base.nix` plus the context modules in `overlays/context/home-manager/`. System overlays are split by concern: `overlays/arch/` for CPU differences, `overlays/context/system/` for work/home tweaks, and `overlays/os/` for Darwin-only adjustments. Application profiles and dotfiles sit under `config/`, grouped by tool (`config/nvim`, `config/tmux`, etc.). `packages/common.nix` exposes named package profiles consumed by both system and home layers, and `install.sh` bootstraps a new machine end to end.

## Build, Test, and Development Commands
Run `./install.sh` to detect the host and apply the correct layers. Use `nix flake check` before committing to ensure the flake and modules evaluate cleanly. To dry-run host changes, use `darwin-rebuild switch --dry-run --flake .#<hostname>` on macOS or `home-manager switch --dry-run --flake .#srv722852` on Linux. When you need to inspect outputs, `nix build .#darwinConfigurations.cortex.system` (or another host key) verifies the system derivation builds.

## Coding Style & Naming Conventions
Prefer two-space indentation in Nix files and keep attribute sets alphabetized where practical. Name new modules after their scope (`modules/<domain>/*.nix`, `overlays/<dimension>/<detail>.nix`) so the layering remains obvious. When extending hosts in `modules/hosts/definitions.nix`, stick to short lowercase keys and reuse the existing attribute schema (`system`, `user`, `isWork`, `packages`). Run `nix fmt` or `alejandra` if available in your environment before pushing.

## Testing Guidelines
Treat `nix flake check` as the minimum gate; add targeted builds for the hosts you touch. For macOS changes, capture the output of `darwin-rebuild switch --dry-run` in your PR to document the resulting rebuild actions. For Linux profiles, share `home-manager switch --dry-run` output. Keep module-level tests idempotent—avoid side-effecting commands inside module definitions.

## Commit & Pull Request Guidelines
Follow the existing history’s style: concise, lower-case subject lines that describe the change (e.g., `adding uv`). Reference affected hosts or contexts in the body when relevant. PRs should summarize the configuration layers touched, link any tracking issues, and paste the dry-run commands you executed. Include screenshots only when UI-facing assets in `config/` change. Ensure reviewers can reproduce your validation steps quickly.
