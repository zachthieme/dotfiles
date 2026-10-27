# Home-specific Home Manager configuration
# (work counterpart: work.nix — add context overrides only when they diverge
# from the shared base: shellAbbrs, home.file, packages, etc.)
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../home-manager/base.nix
    ../../home-manager/programs/claude.nix
  ];

  home.packages = with pkgs;
    [
      claude-code
      # Pi coding agent (binary: `pi`). From nixpkgs rather than
      # `npm install -g @earendil-works/pi-coding-agent`, so it stays pinned by
      # flake.lock like the rest of the toolchain.
      pi-coding-agent
    ]
    # HEY email CLI (`hey`); see dotfiles.hey.
    ++ lib.optional config.dotfiles.hey hey-cli;

  # Home context only, and full profile only, which keeps it off the Pis.
  dotfiles.hey = config.dotfiles.packageProfile == "full";
}
