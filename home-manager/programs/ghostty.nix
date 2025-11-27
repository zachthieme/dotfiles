# Ghostty terminal configuration
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";
      quick-terminal-animation-duration = 0;
      # Enable option-as-alt for fish partial completion
      macos-option-as-alt = true;
      keybind = [
        "global:ctrl+grave_accent=toggle_quick_terminal"
        "alt+left=unbind"
        "alt+right=unbind"
      ];
    };
  };
}
