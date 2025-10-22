# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based dotfiles repository that manages macOS (via nix-darwin) and Linux (via Home Manager) configurations across multiple machines. The architecture uses a layered approach: base system defaults, architecture overlays (aarch64/x86_64), OS-specific settings (Darwin), and context overlays (home/work) that compose together to produce machine-specific configurations.

## Commands

### Initial Setup
```bash
./install.sh  # Auto-detects host and applies appropriate configuration
```

### Rebuilding Configurations

**macOS (nix-darwin):**
```bash
darwin-rebuild switch --flake .#<hostname>
darwin-rebuild switch --dry-run --flake .#<hostname>  # Preview changes
darwin-rebuild switch --show-trace --flake .#<hostname>  # Debug errors
```

**Linux (Home Manager):**
```bash
home-manager switch --flake .#srv722852
home-manager switch --dry-run --flake .#srv722852  # Preview changes
```

### Validation
```bash
nix flake check  # Run before every commit
nix build .#darwinConfigurations.<hostname>.system  # Build system derivation
```

### Formatting
```bash
nix fmt  # Format Nix files (if available)
alejandra .  # Alternative formatter
```

## Architecture

### Flake Structure

The `flake.nix` orchestrates everything:
1. Imports host metadata from `modules/hosts/definitions.nix`
2. Splits hosts into `darwinHosts` and `linuxHosts` based on system attribute
3. Applies appropriate builder: `mkDarwinConfig` (macOS) or `mkHomeConfig` (Linux)
4. Exports `darwinConfigurations` and `homeConfigurations`

### Layer Composition

**macOS hosts** (`modules/darwin/mk-config.nix`) stack these modules:
1. `base/default.nix` - Shared system settings (packages, users, hostname)
2. `overlays/os/darwin.nix` - macOS-only settings (Homebrew, system defaults, keyboard)
3. `overlays/arch/{aarch64,x86_64}.nix` - Architecture-specific tweaks
4. `overlays/context/system/{home,work}.nix` - Context system overrides
5. Inline module with host-specific `local.hostname`, `local.username`, packages
6. Home Manager as Darwin module, importing `overlays/context/home-manager/{home,work}.nix`

**Linux hosts** (`modules/home-manager/mk-config.nix`) load:
1. `overlays/context/home-manager/{home,work}.nix` (which imports `home-manager/base.nix`)
2. Inline module setting `home.username`, `home.homeDirectory`, `home.packages`

### Context Modules

Context modules (`overlays/context/`) determine home vs work environments:
- System context: `overlays/context/system/home.nix` and `work.nix`
- User context: `overlays/context/home-manager/home.nix` and `work.nix`

Both home-manager context modules import `home-manager/base.nix`, which contains shared user settings (zsh, tmux, fzf, dotfile symlinks). This base module is a Home Manager module, so it receives `config.home.username` and `config.home.homeDirectory` from the host wiring.

### Host Definitions

All host metadata lives in `modules/hosts/definitions.nix`:
```nix
{
  "cortex" = {
    system = "aarch64-darwin";
    user = "zach";
    isWork = false;
    packages = [ ];  # Host-specific packages
  };
  # ... more hosts
}
```

The `isWork` flag selects which context modules to load. Add packages here rather than scattering conditionals throughout modules.

### Package Profiles

`packages/common.nix` exports `profiles.basePackages` - a shared list consumed by both `base/default.nix` (system) and `home-manager/base.nix` (user). This ensures consistent tooling across layers.

### Application Configs

Dotfiles are organized under `config/<tool>/` and symlinked via `home.file` in `home-manager/base.nix`:
```nix
home.file = {
  ".config/nvim".source = ../config/nvim;
  ".config/zsh".source = ../config/zsh;
  # ...
};
```

## Key Principles

1. **Single Source of Truth**: Host facts (username, system, isWork) are declared only in `modules/hosts/definitions.nix`. Downstream modules consume them via `config.local.username` or `config.home.username`.

2. **Layer Separation**: Keep shared logic in `base/` and deltas in `overlays/context/`. Avoid repeating base settings in context modules.

3. **Host-Specific Packages**: Prefer adding packages to a host's `packages` list in `definitions.nix` over adding conditionals inside modules.

4. **Idempotent Modules**: Wrap side effects in `lib.mkIf` guards so they only activate on intended systems.

5. **Home Manager Integration**: On macOS, Home Manager runs as a nix-darwin module. On Linux, it's standalone. Both paths converge on the same context modules.

## Adding New Hosts

1. Add entry to `modules/hosts/definitions.nix`:
   ```nix
   "newhostname" = {
     system = "aarch64-darwin";  # or x86_64-darwin, x86_64-linux
     user = "username";
     isWork = true;
     packages = [ ];
   };
   ```
2. Hostname must match the machine's actual hostname
3. Run `./install.sh` or the appropriate rebuild command

## Adding Software

**For all machines**: Add to `profiles.basePackages` in `packages/common.nix`

**For one host**: Add to that host's `packages` list in `definitions.nix`

**Homebrew formulas** (macOS only): Use `pkgs.homebrewPackages.<formula>` in host packages, or add directly to `overlays/os/darwin.nix` for all macOS machines

## Common Patterns

**Access host username in system module**:
```nix
config.local.username
```

**Access username in Home Manager module**:
```nix
config.home.username
```

**Conditional logic based on work context**:
```nix
lib.mkIf config.local.isWork {
  # work-specific settings
}
```

**Add dotfiles for a new tool**:
1. Create `config/<tool>/` directory
2. Add symlink in `home-manager/base.nix` or context module:
   ```nix
   home.file.".config/<tool>".source = ../config/<tool>;
   ```
