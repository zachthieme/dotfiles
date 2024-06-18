local wezterm = require("wezterm")

return {
  color_scheme = "Catppuccin Mocha",
  font = wezterm.font_with_fallback({
    { family = "JetBrains Mono", weight = "Bold" },
    { family = "Hack Nerd Font Mono", weight = "Bold" },
  }),
}
