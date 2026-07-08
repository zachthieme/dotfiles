# Home-specific Home Manager configuration
{pkgs, ...}: {
  imports = [
    ../../home-manager/base.nix
  ];

  # Home-specific shell abbreviations
  programs.fish.shellAbbrs = {
    # Override abbreviations for home machines here
  };

  home.file = {
    # herdr spawns panes with $SHELL (zsh) unless told otherwise; point it at fish.
    # Note: read-only symlink — herdr's own config edits (e.g. `config reset-keys`) won't work.
    ".config/herdr/config.toml".text = ''
      [terminal]
      default_shell = "${pkgs.fish}/bin/fish"
    '';
  };

  home.packages = with pkgs; [
    claude-code
    herdr
  ];
}
