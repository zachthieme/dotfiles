# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based dotfiles repository that manages macOS (via nix-darwin) and Linux (via Home Manager) configurations across multiple machines. The architecture uses a layered approach: base system defaults, OS-specific settings (Darwin), and context overlays (home/work) that compose together to produce machine-specific configurations.

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
1. Imports shared helper functions from `modules/lib.nix`
2. Imports host metadata from `modules/hosts/definitions.nix`
3. Imports hostname detection from `modules/hosts/detect.nix`
4. Splits hosts into `darwinHosts` and `linuxHosts` based on system attribute
5. Applies appropriate builder: `mkDarwinConfig` (macOS) or `mkHomeConfig` (Linux)
6. Passes `helpers` to both builders for shared utilities
7. Exports `darwinConfigurations` (with `default` alias for detected host) and `homeConfigurations`

### Hostname Detection

`modules/hosts/detect.nix` provides automatic hostname detection:
- Reads `HOSTNAME` (Linux) or `HOST` (macOS) environment variables
- If hostname exists in `definitions.nix`, sets it as `defaultHost`
- Enables `darwin-rebuild switch --flake .` without specifying hostname
- Falls back gracefully if hostname not found or not set

### Shared Helper Functions

`modules/lib.nix` provides utilities used across the configuration:
- **`getHomeDirectory user system`**: Returns the appropriate home directory path (`/Users/` for Darwin, `/home/` for Linux)
- **`selectContextModule isWork homeModule workModule`**: Selects the appropriate context module based on the `isWork` flag
- **`isDarwin system`**: Boolean check if system is Darwin/macOS
- **`isLinux system`**: Boolean check if system is Linux

These helpers eliminate code duplication and provide a single source of truth for OS-specific logic.

### Layer Composition

**macOS hosts** (`modules/darwin/mk-config.nix`) stack these modules:
1. `base/darwin.nix` - Shared system settings (packages, users, hostname)
2. `overlays/os/darwin.nix` - macOS-only settings (Homebrew, system defaults, keyboard)
3. `overlays/context/system/{home,work}.nix` - Context system overrides
4. Inline module with host-specific `local.hostname`, `local.username`, packages
5. Home Manager as Darwin module, importing `overlays/context/home-manager/{home,work}.nix`

**Linux hosts** (`modules/home-manager/mk-config.nix`) load:
1. `overlays/context/home-manager/{home,work}.nix` (which imports `home-manager/base.nix`)
2. Inline module setting `home.username`, `home.homeDirectory`, `home.packages`

### Context Modules

Context modules (`overlays/context/`) determine home vs work environments. The appropriate module is selected by the builder using `helpers.selectContextModule` based on the `isWork` flag from `definitions.nix`.

- **System context**: `overlays/context/system/home.nix` and `work.nix` - These modules do NOT set `local.isWork` (it's already set from definitions.nix). They only contain context-specific system packages and settings.
- **User context**: `overlays/context/home-manager/home.nix` and `work.nix` - User-level context differences.

Both home-manager context modules import `home-manager/base.nix`, which contains shared user settings (fish, fzf, program imports, dotfile symlinks). This base module is a Home Manager module, so it receives `config.home.username` and `config.home.homeDirectory` from the host wiring (set via `helpers.getHomeDirectory`).

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

`packages/common.nix` exports `profiles.basePackages` - a shared list consumed by both `base/darwin.nix` (system) and `home-manager/base.nix` (user). This ensures consistent tooling across layers.

### Program Configurations

Program-specific Home Manager configurations live in `home-manager/programs/`:
- `bat.nix`, `btop.nix` - Terminal utilities
- `fish.nix` - Shell configuration with functions and abbreviations
- `git.nix` - Git settings and delta pager
- `ghostty.nix`, `helix.nix` - Terminal and editor
- `jujutsu.nix`, `lazygit.nix` - VCS tools
- `ssh.nix` - SSH configuration
- `zellij.nix` - Terminal multiplexer

These are imported by `home-manager/base.nix` and apply to all hosts.

### Application Configs

Static dotfiles are organized under `config/<tool>/` and symlinked via `home.file` in `home-manager/base.nix`:
```nix
home.file = {
  ".config/aerospace".source = ../config/aerospace;
  ".config/borders".source = ../config/borders;
  ".config/jrnl".source = ../config/jrnl;
  ".config/ripgrep".source = ../config/ripgrep;
  # ...
};
```

## Code Style

- **Indentation**: Two spaces in Nix files
- **Attribute ordering**: Alphabetize attribute sets where practical
- **Module naming**: Follow existing patterns (`modules/<domain>/*.nix`, `overlays/<dimension>/<detail>.nix`)
- **Host keys**: Use short lowercase names in `definitions.nix`
- **Formatting**: Run `nix fmt` or `alejandra .` before committing
- **Commit messages**: Concise, lowercase subject lines describing the change (e.g., `adding uv`, `fix fish path on linux`)

## Key Principles

1. **Single Source of Truth**: Host facts (username, system, isWork) are declared only in `modules/hosts/definitions.nix`. Downstream modules consume them via `config.local.username` or `config.home.username`. Never re-declare these values in overlay modules.

2. **No Duplication**: Use shared helper functions from `modules/lib.nix` for any logic that appears in multiple places. OS detection, path resolution, and module selection should use helpers rather than inline logic.

3. **Layer Separation**: Keep shared logic in `base/` and deltas in `overlays/context/`. Avoid repeating base settings in context modules.

4. **Host-Specific Packages**: Prefer adding packages to a host's `packages` list in `definitions.nix` over adding conditionals inside modules.

5. **Idempotent Modules**: Wrap side effects in `lib.mkIf` guards so they only activate on intended systems.

6. **Home Manager Integration**: On macOS, Home Manager runs as a nix-darwin module. On Linux, it's standalone. Both paths converge on the same context modules.

7. **Platform-Specific System Configs**: The `base/darwin.nix` module contains macOS system configuration. Future NixOS machines would use a separate `base/nixos.nix` module with similar structure but NixOS-specific settings.

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

**Homebrew casks/formulas** (macOS only): Add to the appropriate context module in `overlays/context/system/` for context-specific apps (e.g., different browsers for home vs work), or add directly to `overlays/os/darwin.nix` for all macOS machines

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

**Use helper functions in builders** (when creating new builders or modifying existing ones):
```nix
{ helpers, ... }:  # Accept helpers as parameter
# ...
let
  homeDir = helpers.getHomeDirectory user system;
  contextModule = helpers.selectContextModule isWork homeModule workModule;
in
# ...
```

**OS detection in modules** (use standard library functions):
```nix
lib.mkIf pkgs.stdenv.isDarwin {
  # Darwin-specific settings
}

lib.mkIf pkgs.stdenv.isLinux {
  # Linux-specific settings
}
```

**Add dotfiles for a new tool**:
1. Create `config/<tool>/` directory for static configs
2. Add symlink in `home-manager/base.nix` or context module:
   ```nix
   home.file.".config/<tool>".source = ../config/<tool>;
   ```

**Add a new program module** (for tools with Home Manager options):
1. Create `home-manager/programs/<tool>.nix`
2. Import it in `home-manager/base.nix`:
   ```nix
   imports = [
     ./programs/<tool>.nix
   ];
   ```

**Configure Fish shell** (prefer declarative Home Manager options over shell scripts):
```nix
programs.fish = {
  enable = true;

  # Shell-level initialization (runs in all fish shells)
  shellInit = ''
    set -g fish_greeting
  '';

  # Interactive shell initialization only
  interactiveShellInit = ''
    fish_vi_key_bindings
    set -g fish_term24bit 1
  '';

  # Abbreviations (preferred over inline abbr commands)
  shellAbbrs = {
    vi = "hx";
    gs = "git status";
  };

  # Functions (preferred over inline function definitions)
  functions = {
    my_function = {
      description = "Brief description shown by 'functions -D'";
      body = ''
        # Function implementation
        echo "Hello $argv"
      '';
    };
  };
};

# Use native integrations for tools
programs.carapace.enable = true;
programs.carapace.enableFishIntegration = true;
programs.fzf.enableFishIntegration = true;
programs.zoxide.enableFishIntegration = true;
```

## Platform Differences

### Home Manager Backup File Extension

When Home Manager encounters existing files that would be clobbered, the backup mechanism differs by platform:

**macOS (nix-darwin module)**: Use `home-manager.backupFileExtension` in the darwin module config:
```nix
# In modules/darwin/mk-config.nix
home-manager.backupFileExtension = "backup";
```

**Linux (standalone Home Manager)**: The `home.backupFileExtension` option does NOT exist. Instead, use the `-b` flag in the command line:
```bash
home-manager switch -b backup --flake .#hostname
```

This is handled automatically in `install.sh` for Linux hosts.

### Linux Home Manager PATH

On standalone Home Manager (Linux), packages are installed to a different location than macOS:

**Linux**: `~/.local/state/nix/profiles/home-manager/home-path/bin`
**macOS**: Managed by nix-darwin, packages available system-wide

The `install.sh` script automatically:
1. Configures `~/.bashrc` with the Home Manager PATH
2. Sources `hm-session-vars.sh` for environment variables

Fish shell has this path added via `fish_add_path` in `home-manager/programs/fish.nix`.

### Default Shell Change (Linux)

On Linux, changing the default shell to fish requires manual steps after installation:

```bash
echo "$HOME/.local/state/nix/profiles/home-manager/home-path/bin/fish" | sudo tee -a /etc/shells
chsh -s "$HOME/.local/state/nix/profiles/home-manager/home-path/bin/fish"
```

Then log out and back in. This cannot be automated because:
- Adding to `/etc/shells` requires sudo
- `chsh` requires the user's password interactively

The `install.sh` script prints a reminder with the exact commands to run.

### Nix Experimental Features

The `install.sh` script uses explicit `--extra-experimental-features` flags rather than the `NIX_CONFIG` environment variable because:
- Standard Nix installations (non-Determinate) don't enable flakes/nix-command by default
- The `NIX_CONFIG` env var isn't reliably respected across all Nix versions (discovered on Raspberry Pi with Nix 2.25.3)
- Explicit flags work consistently across Nix 2.4+ and Determinate Nix

The script defines `NIX_FLAGS` and uses it for all `nix` commands:
```bash
NIX_FLAGS="--extra-experimental-features nix-command --extra-experimental-features flakes"
nix $NIX_FLAGS profile add nixpkgs#home-manager
```

### Home Manager Option Naming (as of 2025)

Some Home Manager options have been renamed. Use the new names:
- `programs.git.userName` → `programs.git.settings.user.name`
- `programs.git.userEmail` → `programs.git.settings.user.email`
- `programs.git.extraConfig` → merge into `programs.git.settings`
- `programs.git.delta.enable` → `programs.delta.enable`
- `programs.git.delta.options` → `programs.delta.options`
- `programs.ssh` requires `enableDefaultConfig = false` to suppress deprecation warnings

## Recent Refactorings

### 2025-11-04: Code Deduplication and Helper Library

**Motivation**: Eliminate duplication, establish single source of truth, prepare for multi-OS support (Ubuntu, Arch, Raspbian).

**Changes**:
1. **Created `modules/lib.nix`**: Shared helper functions for path resolution, OS detection, and module selection
2. **Eliminated home directory path duplication**: Removed identical logic from both `darwin/mk-config.nix` and `home-manager/mk-config.nix`, replaced with `helpers.getHomeDirectory`
3. **Standardized context module selection**: Replaced repeated if-then-else with `helpers.selectContextModule`
4. **Removed redundant isWork assignments**: Context system modules no longer re-set `local.isWork` since it's already defined in `definitions.nix`
5. **Made base module OS-agnostic**: Updated `base/darwin.nix` (formerly `base/default.nix`) to use `pkgs.stdenv.isDarwin` for conditional paths, removed "MacBook" reference. Later renamed to `base/darwin.nix` to clarify it's macOS-specific.

**Impact**:
- Zero code duplication for OS detection and path resolution
- Single source of truth for all host metadata
- Easier to add support for new Linux distributions
- More maintainable and consistent codebase

### 2025-11-26: Fish Shell Configuration Modernization

**Motivation**: Migrate from zsh to fish, convert shell functions properly, and use declarative Home Manager options instead of imperative shell scripts.

**Changes**:
1. **Converted zsh functions to fish**: Migrated core functions to fish syntax (gff, k, logg, mkdd, fif, fifs, fifc, nix-cleanup, ft, _fif_common)
2. **Adopted `programs.fish.functions`**: Moved all function definitions from `interactiveShellInit` string blocks to structured `programs.fish.functions` attributes with descriptions
3. **Migrated to `programs.fish.shellAbbrs`**: Converted inline `abbr -a` commands to declarative `shellAbbrs` attribute set
4. **Standardized environment variables**: Moved `COLORTERM` from fish config to `home.sessionVariables` for global availability
5. **Consolidated PATH management**: Eliminated redundant `fish_add_path` calls by using `home.sessionPath` with conditional Darwin paths via `lib.optionals`
6. **Native tool integrations**: Replaced manual carapace sourcing with `programs.carapace.enableFishIntegration`
7. **Separated shell initialization**: Distinguished between `shellInit` (all shells) and `interactiveShellInit` (interactive only)

**Impact**:
- Cleaner, more maintainable fish configuration following Home Manager best practices
- Functions are properly structured with descriptions and metadata
- Better separation between declarative config and imperative shell code
- Easier to selectively enable/disable functions or abbreviations
- Reduced code in string blocks, more native Nix attributes
- Tool integrations managed by Home Manager instead of manual sourcing
