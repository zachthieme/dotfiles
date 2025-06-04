# Work M1 MacBook configuration
{ pkgs, lib, ... }:

{
  # Set hostname for this machine
  local.hostname = "zthieme34911";

  # Import base configuration
  imports = [
    ../../base/default.nix
    ../../overlays/arch/aarch64.nix
    ../../overlays/context/work.nix
  ];

  # M1-specific packages for work (if any)
  environment.systemPackages = with pkgs; [
    # Add any M1-specific packages for work
  ];

  # M1-specific homebrew casks for work (if any)
  # homebrew.casks = [ ... ];
}