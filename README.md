# Dotfiles for Multiple Machines

This repository contains configurations for several machines:
- Home M4 MacBook
- Home Intel MacBook
- Work M1 MacBook
- `srv722852` (Home x86_64 Linux)

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
├── config/              # Shared application configurations
├── flake.nix            # Main entry point with host definitions
└── install.sh           # Installation script
```

## Installation

Run the installation script:

```bash
./install.sh
```

The script will:
1. Detect your machine type (hostname and architecture)
2. Install necessary dependencies (nix, plus nix-darwin and Homebrew on macOS or home-manager on Linux)
3. Apply the appropriate configuration
4. Automatically select the correct home-manager configuration based on machine context

## Customization

### Adding a new machine

1. Add a new entry to the `hosts` attribute in `flake.nix`
2. Specify the hostname, system architecture, username, and work/home context
3. Add any machine-specific packages if needed

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
   - No host-specific home.nix files are needed; configurations are selected automatically based on context

3. **Functional Flake Design**:
   - The main `flake.nix` uses a functional approach to generate configurations
   - Machine properties are defined in a single place and used to derive configurations
   - Imports the correct home-manager modules based on context (home vs. work)

4. **Layered Approach**:
   - Base → Architecture → Context → Host-specific settings in flake.nix
   - Each layer only defines what's unique to that layer
   - Host-specific settings defined directly in the flake.nix, eliminating an entire layer of files

## Manual Configuration

If automatic detection doesn't work, you can manually apply a configuration:

```bash
# macOS
darwin-rebuild switch --flake ~/dotfiles#[configuration-name]

# Linux
home-manager switch --flake ~/dotfiles#srv722852
```

Where `[configuration-name]` for macOS is one of:
- `cortex` (Home M4 MacBook)
- `malv2` (Home Intel MacBook)
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
    packages = with pkgs; [
      # Add any host-specific packages here
    ];
  };
};
```

That's it! The architecture-specific and context-specific modules will be automatically selected based on the `system` and `isWork` properties, and the hostname will be set based on the key.
