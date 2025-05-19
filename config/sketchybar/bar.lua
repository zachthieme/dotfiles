local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
  topmost = "window",
  height = 40,
  corner_radius = 10,
  color = colors.bar.bg,
  notch_width = 188,
  blur_radius = 20,
  sticky = true,
  font_smoothing = true,
  padding_right = 2,
  padding_left = 2,
})
