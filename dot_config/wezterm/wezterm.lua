local wezterm = require("wezterm")

return {
  -- ...your existing config
  color_scheme = "Catppuccin Mocha", -- or Macchiato, Frappe, Latte
  hide_tab_bar_if_only_one_tab = true,
  -- font = wezterm.font("JetBrains Mono"),
  -- font = wezterm.font_with_fallback({ "Hack Nerd Font Mono", "JetBrains Mono" }),
  wezterm.font("Roboto", { weight = 250, stretch = "Normal", style = "Normal" }),
  -- font = wezterm.font_with_fallback({ "JetBrains Mono", "Hack Nerd Font Mono" }),
}
