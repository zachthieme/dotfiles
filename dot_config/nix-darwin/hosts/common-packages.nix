{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    curl
    dotnetCorePackages.dotnet_9.runtime
    dotnetCorePackages.dotnet_9.sdk
    emacs
    eza
    fd
    fzf
    gh
    git
    go
    gotools
    jq
    mosh
    neovim
    nixfmt-rfc-style
    nodejs_23
    pandoc
    pass
    python3
    ripgrep
    tmux
    vim
    wget
    yazi
    zoxide
    zsh
  ];

  homebrew = {
    enable = true;
    taps = [
      "FelixKratz/formulae"
    ];
    brews = [
      "FelixKratz/formulae/borders"
      "FelixKratz/formulae/sketchybar"
      "oh-my-posh"
      "spotify_player"
    ];
    casks = [
      "balenaetcher"
      "bartender"
      "brave-browser"
      "dropbox"
      "ghostty"
      "homerow"
      "nikitabobko/tap/aerospace"
      "raycast"
      "spotify"
      "wezterm"
      "zed"
    ];
  };
  # configuring mac os
  # use touchid in terminal
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;

    # aerospace configuration
    dock.mru-spaces = false;
    dock.expose-group-apps = true;
    spaces.spans-displays = true;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
  };
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

}
