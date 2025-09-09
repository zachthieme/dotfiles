# Work-specific Home Manager configuration
{ pkgs, lib, ... }:

let
  username = "zthieme";
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  # Import the base configuration with our username and home directory
  imports = [
    (import ./base.nix {
      inherit pkgs username homeDirectory;
      # Pass minimal-tmux if needed for work configuration
      # minimal-tmux = minimal-tmux;
    })
  ];

  # Override cat alias to use standard cat at work
  programs.zsh.shellAliases = {
  };

  # Work-specific file symlinks
  home.file = {
    # Work doesn't need sketchybar
    # ".config/sketchybar".source = null;
  };

  # Work-specific package overrides
  # Uncomment and modify as needed
  # home.packages = with pkgs; [
  #   # Add work-specific packages here
  # ];

  # Work-specific program configurations
  # These will be merged with the ones from base.nix
  # programs.some-program.settings = { ... };
}
