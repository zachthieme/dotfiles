# Home Intel MacBook configuration
{ pkgs, lib, ... }:

{
  # Set hostname for this machine
  local.hostname = "cortex-intel";

  # Import base configuration
  imports = [
    ../../base/default.nix
    ../../overlays/arch/x86_64.nix
    ../../overlays/context/home.nix
  ];

  # Intel-specific packages (if any)
  environment.systemPackages = with pkgs; [
    # Add any Intel-specific packages here
  ];

  # Intel-specific homebrew casks (if any)
  # homebrew.casks = [ ... ];
}