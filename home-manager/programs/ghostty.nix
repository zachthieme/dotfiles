# Ghostty terminal configuration
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = null;
    enableFishIntegration = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";
      quick-terminal-animation-duration = 0;
      # Enable option-as-alt for fish partial completion
      macos-option-as-alt = true;
      keybind = [
        ''alt+shift+0=text:\x1b)''
        ''alt+shift+9=text:\x1b(''
        "global:ctrl+grave_accent=toggle_quick_terminal"
        "alt+left=unbind"
        "alt+right=unbind"
      ];
    };
  };
}
