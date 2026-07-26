# Home-specific system configuration
# This module is loaded for non-work machines (isWork = false in definitions.nix)
# Add home-specific system packages, brews, or macOS defaults here as needed.
{...}: {
  # trusted: required since Homebrew 6.0.0 — see the taps comment in
  # system/darwin.nix.
  homebrew.taps = [
    {
      name = "siderolabs/tap";
      trusted = true;
    }
  ];
  # Kubernetes/Talos tooling — Homebrew rather than nixpkgs because these track
  # cluster-side versions and siderolabs ships no nixpkgs package.
  homebrew.brews = [
    "cilium-cli"
    "helm"
    "kubelogin"
    "kubernetes-cli"
    "siderolabs/tap/omnictl"
    "siderolabs/tap/sidero-tools"
    "siderolabs/tap/talosctl"
    "tetra"
  ];
  homebrew.casks = [
    "brave-browser"
    "docker-desktop"
    "raycast"
  ];
}
