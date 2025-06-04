# Work-specific Home Manager configuration
{ pkgs, lib, ... }:

let
  username = "zthieme";
  homeDirectory = "/Users/${username}";
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
    cat = null; # Remove the bat alias from base config
  };

  # Enable fish shell at work
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  # Work-specific file symlinks
  home.file = {
    # Work doesn't need sketchybar
    # ".config/sketchybar".source = null;

    # Add any work-specific symlinks here
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
