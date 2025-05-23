local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local icon_color = colors.grey
local icon_string = "?"

local front_app = sbar.add("item", "front_app", {
  display = "active",
  icon = { drawing = false },
  position = "q",
  label = {
    color = colors.green,
    font = {
      style = settings.font.style_map["Green"],
      size = 15.0,
    },
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({
    label = {
      string = env.INFO,
    },
  })
end)
sbar.exec("sketchybar --reorder calendar before front_app")
