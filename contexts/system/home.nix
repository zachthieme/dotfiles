# Home-specific system configuration
# This module is loaded for non-work machines (isWork = false in definitions.nix)
# Add home-specific system packages, brews, or macOS defaults here as needed.
{...}: {
  homebrew.casks = [
    "brave-browser"
    "codex"
    "docker-desktop"
    "raycast"
  ];
}
