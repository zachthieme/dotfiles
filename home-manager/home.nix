# Home-specific Home Manager configuration
{ pkgs, lib, ... }:

let
  username = "zach";
  homeDirectory = "/Users/${username}";
in
{
  # Import the base configuration with our username and home directory
  imports = [
    (import ./base.nix {
      inherit pkgs username homeDirectory;
    })
  ];

  # Home-specific file symlinks
  home.file = {
    # Add home-specific symlinks here
    # ".config/sketchybar".source = ../config/sketchybar;
  };

  # Home-specific package overrides
  # Uncomment and modify as needed
  # home.packages = with pkgs; [
  #   # Add home-specific packages here
  # ];

  # Home-specific program configurations
  # These will be merged with the ones from base.nix
  # programs.some-program.settings = { ... };
}
