# Work-specific system configuration
# This module is loaded for work machines (isWork = true in definitions.nix)
# Add work-specific system packages, brews, or macOS defaults here as needed.
{...}: {
  homebrew.casks = [
    "google-chrome"
  ];
}
