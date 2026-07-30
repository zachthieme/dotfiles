# Home-specific Home Manager configuration
# (work counterpart: work.nix — add context overrides only when they diverge
# from the shared base: shellAbbrs, home.file, packages, etc.)
{pkgs, ...}: {
  imports = [
    ../../home-manager/base.nix
  ];

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
    # Pi coding agent (binary: `pi`). From nixpkgs rather than
    # `npm install -g @earendil-works/pi-coding-agent`, so it stays pinned by
    # flake.lock like the rest of the toolchain.
    pi-coding-agent
  ];
}
