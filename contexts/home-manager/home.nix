# Home-specific Home Manager configuration
# (work counterpart: work.nix — add context overrides only when they diverge
# from the shared base: shellAbbrs, home.file, packages, etc.)
{pkgs, ...}: {
  imports = [
    ../../home-manager/base.nix
    ../../home-manager/programs/claude.nix
  ];

  home.packages = with pkgs; [
    claude-code
    # Pi coding agent (binary: `pi`). From nixpkgs rather than
    # `npm install -g @earendil-works/pi-coding-agent`, so it stays pinned by
    # flake.lock like the rest of the toolchain.
    pi-coding-agent
  ];
}
