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

  # Remote Login (System Settings > General > Sharing). This hands nix-darwin
  # the enable/disable of Apple's built-in sshd — same daemon the GUI toggle
  # drives, just declared here so a rebuilt machine comes up with it on instead
  # of needing a manual flip.
  #
  # Two things it does NOT cover, because nix-darwin has no option for either:
  #   - Who may log in. macOS defaults Remote Login to ALL users; narrowing it
  #     to an access_ssh group is a GUI/dseditgroup step.
  #   - Disabling password auth. That means editing sshd_config by hand.
  services.openssh.enable = true;
}
