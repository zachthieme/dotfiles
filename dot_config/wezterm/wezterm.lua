local wezterm = require("wezterm")

return {
  color_scheme = "Catppuccin Mocha",
  font = wezterm.font_with_fallback({
    { family = "Hack Nerd Font Mono", weight = "Bold" },
    { family = "JetBrains Mono", weight = "Bold" },
    enable_tab_bar = false,
    window_decorations = "RESIZE",
  }),
}
