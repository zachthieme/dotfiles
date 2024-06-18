local wezterm = require("wezterm")

return {
  font = wezterm.font_with_fallback({
    { family = "Hack Nerd Font Mono", weight = "Bold" },
    { family = "JetBrains Mono", weight = "Bold" },
  }),
}
