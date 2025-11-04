# x86_64 architecture-specific configuration
# Used for: Intel Macs (x86_64-darwin), Ubuntu/Arch Linux (x86_64-linux)
# The hostPlatform is set from the system attribute in definitions.nix
{ pkgs, lib, ... }:

{
  # x86_64-specific packages
  # Example: packages that only make sense on x86_64 or have x86-optimized versions
  environment.systemPackages = with pkgs; [
    # Add x86_64-specific packages here when needed
  ];

  # x86_64-specific homebrew casks (Darwin only)
  # homebrew.casks = [ ... ];
}