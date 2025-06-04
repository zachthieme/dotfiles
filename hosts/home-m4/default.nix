# Home M4 MacBook configuration
{ pkgs, lib, ... }:

{
  # Set hostname for this machine
  local.hostname = "cortex-m4";

  # Import base configuration
  imports = [
    ../../base/default.nix
    ../../overlays/arch/aarch64.nix
    ../../overlays/context/home.nix
  ];

  # M4-specific packages (if any)
  environment.systemPackages = with pkgs; [
    # Add any M4-specific packages here
  ];

  # M4-specific homebrew casks (if any)
  # homebrew.casks = [ ... ];
}