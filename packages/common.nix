{ pkgs }:
let
  inherit (pkgs.stdenv) isLinux;
in
{
  profiles = rec {
    # Essential CLI tools - always installed on all machines including Pi
    corePackages = with pkgs; [
      bat
      btop
      curl
      eza
      fd
      gh
      git
      jq
      jrnl
      jujutsu
      lazyjj
      less
      markdown-oxide # LSP for notes
      marksman # LSP for notes
      ripgrep
      tree
      unzip
      vivid
      wget
      watch
      which
      zsh
    ] ++ pkgs.lib.optionals isLinux [
      helix # Darwin installs at system level
      vault # Darwin installs at system level
    ];

    # Development tools - compilers, LSPs, formatters
    devPackages = with pkgs; [
      bazelisk
      bash-language-server
      mosh
      nixd
      clang-tools
      delve
      devbox
      devenv
      gcc
      go
      golangci-lint
      golangci-lint-langserver
      gopls
      gotools
      lldb_20
      gnumake
      nixfmt
      nodejs_24
      openssl
      openssl.dev
      pandoc
      pkg-config
      prettier
      python3
      python312Packages.pdf2docx
      rustup
      slides
      typst
      uv
      zig
      zls
    ] ++ pkgs.lib.optionals isLinux [
      pkgs.libgcc # Linux only
      docker
      docker-compose
    ];

    # Heavy/specialized - resource-intensive packages
    heavyPackages = with pkgs; [
      exiftool
      imagemagick
      pngcheck
      pngcrush
      pngquant
    ];

    # Convenience: full = everything (default behavior for workstations)
    basePackages =
      corePackages
      ++ devPackages
      ++ heavyPackages;
  };
}
