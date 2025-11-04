# ARM64 architecture-specific configuration
# Used for: M-series Macs (aarch64-darwin), Raspberry Pi (aarch64-linux)
# The hostPlatform is set from the system attribute in definitions.nix
{ pkgs, lib, ... }:

{
  # ARM-specific packages
  # Example: packages that only make sense on ARM or have ARM-optimized versions
  environment.systemPackages = with pkgs; [
    # Add ARM-specific packages here when needed
  ];

  # ARM-specific homebrew casks (Darwin only)
  # homebrew.casks = [ ... ];
}