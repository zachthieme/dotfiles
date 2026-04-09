# Ghostty terminal configuration
# - macOS: installed via Homebrew (package = null)
# - Linux: installed via Nix (package = pkgs.ghostty)
{ pkgs, lib, ... }:

{
  # Disable catppuccin's ghostty integration — its theme file uses # in hex
  # colors (palette = 0=#45475a) which ghostty treats as comments
  catppuccin.ghostty.enable = false;

  programs.ghostty = {
    enable = true;
    # Homebrew manages ghostty on macOS, Nix on Linux
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
    enableFishIntegration = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";
      quick-terminal-animation-duration = 0;
      macos-option-as-alt = true;
      theme = "catppuccin-mocha";
      keybind = [
        "alt+left=unbind"
        "alt+right=unbind"
        "alt+shift+0=text:\\x1b)"
        "alt+shift+9=text:\\x1b("
      ];
    };
    # Define catppuccin-mocha theme inline without # in hex colors
    themes.catppuccin-mocha = {
      palette = [
        "0=45475a"
        "1=f38ba8"
        "2=a6e3a1"
        "3=f9e2af"
        "4=89b4fa"
        "5=f5c2e7"
        "6=94e2d5"
        "7=a6adc8"
        "8=585b70"
        "9=f38ba8"
        "10=a6e3a1"
        "11=f9e2af"
        "12=89b4fa"
        "13=f5c2e7"
        "14=94e2d5"
        "15=bac2de"
      ];
      background = "1e1e2e";
      foreground = "cdd6f4";
      cursor-color = "f5e0dc";
      cursor-text = "11111b";
      selection-background = "353749";
      selection-foreground = "cdd6f4";
      split-divider-color = "313244";
    };
  };
}
