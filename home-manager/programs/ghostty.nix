# Ghostty terminal configuration
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    # I install ghostty from brew so package set to null
    package = null;
    enableFishIntegration = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";
      quick-terminal-animation-duration = 0;
      # Enable option-as-alt for fish partial completion
      macos-option-as-alt = true;
      keybind = [
        # These ensure that alt+) and alt+( work in zellij
        ''alt+shift+0=text:\x1b)''
        ''alt+shift+9=text:\x1b(''
        "global:ctrl+grave_accent=toggle_quick_terminal"
        "alt+left=unbind"
        "alt+right=unbind"
        "alt+shift+0=text:\x1b)"
        "alt+shift+9=text:\x1b("
      ];
    };
  };
}
