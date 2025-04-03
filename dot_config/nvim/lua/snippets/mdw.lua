local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

-- function to return current date in yyyy-mm-dd format
local function current_date()
  return os.date("%Y-%m-%d")
end

-- function to return the weekday name
local function weekday()
  return os.date("%A")
end

return {
  s("daily", {
    t("# "),
    f(weekday, {}),
    t(" "),
    f(current_date, {}),
    t({ "", "- Meetings", "", "- Notes" }),
  }),
}
