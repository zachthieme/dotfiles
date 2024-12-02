local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font_with_fallback({
  { family = "Hack Nerd Font Mono", weight = "Bold" },
  { family = "JetBrains Mono", weight = "Bold" },
})
config.enable_tab_bar = false
config.window_decorations = "RESIZE"

return config
