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
└── install.sh           # Installation script
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

## Customization

### Adding a new machine

1. Create a new directory under `hosts/`
2. Create a `default.nix` file importing the appropriate base, architecture, and context
3. Add any machine-specific configurations
4. Add the machine to `flake.nix`

### Modifying shared configurations

- Edit files in `base/` for changes that should apply to all machines
- Edit files in `overlays/arch/` for architecture-specific changes
- Edit files in `overlays/context/` for context-specific changes (home vs. work)

## Manual Configuration

If automatic detection doesn't work, you can manually apply a configuration:

```bash
darwin-rebuild switch --flake ~/dotfiles#[configuration-name]
```

Where `[configuration-name]` is one of:
- `cortex-m4` (Home M4 MacBook)
- `cortex-intel` (Home Intel MacBook)
- `zthieme34911` (Work M1 MacBook)