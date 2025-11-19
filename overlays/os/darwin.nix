# macOS-specific system configuration
{ pkgs, ... }:
{
  # Nix configuration
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Homebrew packages and casks
  homebrew = {
    enable = true;
    taps = [
      "FelixKratz/formulae"
    ];
    brews = [
      "FelixKratz/formulae/borders"
      "spotify_player"
    ];
    casks = [
      "balenaetcher"
      "bartender"
      "dropbox"
      "ghostty"
      "homerow"
      "keycastr"
      "logi-options+"
      "nikitabobko/tap/aerospace"
      "spotify"
      "zed"
    ];
  };

  # macOS defaults
  system.defaults = {
    dock.autohide = true;
    dock.expose-group-apps = true;
    dock.expose-animation-duration = 0.1;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    finder.ShowPathbar = true;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
    spaces.spans-displays = true;
  };

  # Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Enable zsh as a system shell
  programs.zsh.enable = true;
}
