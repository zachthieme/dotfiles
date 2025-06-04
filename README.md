# Dotfiles for Multiple MacBooks

This repository contains configurations for 3 different MacBooks:
- Home M4 MacBook
- Home Intel MacBook
- Work M1 MacBook

## Structure

The repository is organized to minimize duplication while allowing for machine-specific customizations:

```
dotfiles/
├── base/                # Shared base configuration for all machines
├── home-manager/        # Shared Home Manager configurations
│   ├── base.nix         # Base Home Manager config
│   ├── home.nix         # Home-specific extensions
│   └── work.nix         # Work-specific extensions
├── overlays/
│   ├── arch/            # Architecture-specific settings
│   │   ├── aarch64.nix  # M-series specific settings
│   │   └── x86_64.nix   # Intel specific settings
│   └── context/         # Context-specific settings
│       ├── home.nix     # Home-specific settings
│       └── work.nix     # Work-specific settings
├── hosts/               # Specific host configurations
│   ├── home-m4/         # Home M4 MacBook
│   ├── home-intel/      # Home Intel MacBook
│   └── work-m1/         # Work M1 MacBook
├── config/              # Shared application configurations
├── flake.nix            # Main entry point
├── install.sh           # Installation script
└── migrate.sh           # Migration script
```

## Installation

Run the installation script:

```bash
./install.sh
```

The script will:
1. Detect your machine type (hostname and architecture)
2. Install necessary dependencies (nix, nix-darwin, homebrew)
3. Apply the appropriate configuration

### Migration from Previous Structure

If you're transitioning from the old structure, use the migration script:

```bash
./migrate.sh
```

This script helps you:
1. Apply the new configuration
2. Fix file permissions if needed
3. Clean up redundant files and directories

## Customization

### Adding a new machine

1. Create a new directory under `hosts/`
2. Create a `default.nix` file importing the appropriate base, architecture, and context
3. Add any machine-specific configurations
4. Add the machine to the `hosts` attribute in `flake.nix`

### Modifying shared configurations

- Edit `base/default.nix` for system settings that apply to all machines
- Edit `home-manager/base.nix` for user settings that apply to all machines
- Edit files in `overlays/arch/` for architecture-specific changes
- Edit files in `overlays/context/` for context-specific changes (home vs. work)
- Edit `home-manager/home.nix` or `home-manager/work.nix` for context-specific user settings

## How Duplication is Minimized

This structure eliminates duplication in several ways:

1. **Shared System Configuration**:
   - Common packages, homebrew settings, and macOS defaults are defined once in `base/default.nix`
   - Host-specific settings extend this base rather than duplicating it

2. **Shared Home Manager Configuration**:
   - Common dotfiles, program settings, and shell configurations are defined once in `home-manager/base.nix`
   - Context-specific overrides only specify differences

3. **Functional Flake Design**:
   - The main `flake.nix` uses a functional approach to generate configurations
   - Machine properties are defined in a single place and used to derive configurations

4. **Layered Approach**:
   - Base → Architecture → Context → Host specifics
   - Each layer only defines what's unique to that layer

## Manual Configuration

If automatic detection doesn't work, you can manually apply a configuration:

```bash
darwin-rebuild switch --flake ~/dotfiles#[configuration-name]
```

Where `[configuration-name]` is one of:
- `cortex-m4` (Home M4 MacBook)
- `cortex-intel` (Home Intel MacBook)
- `zthieme34911` (Work M1 MacBook)
- `default` (Auto-detected based on hostname and architecture)

## Example: Adding a Configuration

To add a new configuration for another machine:

1. Add the host definition in `flake.nix`:
```nix
hosts = {
  # Existing hosts...
  "new-machine" = {
    system = "aarch64-darwin"; # or x86_64-darwin
    user = "username";
    isWork = true; # or false
  };
};
```

2. Create the host-specific directory and configuration:
```bash
mkdir -p dotfiles/hosts/new-machine
touch dotfiles/hosts/new-machine/default.nix
```

3. Define minimal host-specific settings:
```nix
# new-machine configuration
{ pkgs, lib, ... }:

{
  # Set hostname
  local.hostname = "new-machine";

  # Import appropriate base configurations
  imports = [
    ../../base/default.nix
    ../../overlays/arch/aarch64.nix  # or x86_64.nix
    ../../overlays/context/work.nix  # or home.nix
  ];

  # Machine-specific packages (if any)
  environment.systemPackages = with pkgs; [
    # Add any machine-specific packages here
  ];
}
```