# Ghostty terminal configuration
# - macOS: installed via Homebrew (package = null)
# - Linux: installed via Nix (package = pkgs.ghostty)
{ pkgs, lib, ... }:

{
  programs.ghostty = {
    enable = true;
    # Homebrew manages ghostty on macOS, Nix on Linux
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
    enableFishIntegration = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";
      quick-terminal-animation-duration = 0;
      macos-option-as-alt = true;
      keybind = [
        "global:ctrl+grave_accent=toggle_quick_terminal"
        "alt+left=unbind"
        "alt+right=unbind"
        "alt+shift+0=text:\x1b)"
        "alt+shift+9=text:\x1b("
      ];
    };
  };
}
