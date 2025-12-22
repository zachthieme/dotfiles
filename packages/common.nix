{ pkgs }:
{
  profiles = {
    # Essential CLI tools - always installed on all machines including Pi
    corePackages = with pkgs; [
      bat
      btop
      carapace
      curl
      eza
      fd
      fish
      fzf
      gh
      git
      helix
      jq
      jujutsu
      lazygit
      lazyjj
      less
      markdown-oxide
      marksman
      mosh
      nixd
      nixfmt-rfc-style
      pandoc
      prettier
      ripgrep
      tree
      typst
      unzip
      vivid
      wget
      which
      yazi
      zellij
      zoxide
      zsh
    ];

    # Development tools - compilers, LSPs, formatters
    devPackages = with pkgs; [
      bash-language-server
      delve
      devbox
      gcc
      go
      golangci-lint
      golangci-lint-langserver
      gopls
      gotools
      libgcc
      lldb_20
      gnumake
      nodejs_24
      openssl
      openssl.dev
      pkg-config
      python3
      python312Packages.pdf2docx
      rustup
      uv
      zig
      zls
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
