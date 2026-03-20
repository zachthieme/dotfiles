-- Mini.clue configuration — mirrors Helix's space menu.
-- Each group below corresponds to a Helix top-level menu entry.
local miniclue = require("mini.clue")

miniclue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
  },

  clues = {
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),

    -- Helix: space+f → file picker menu
    { mode = "n", keys = "<Leader>f", desc = "+Files" },
    -- Helix: space+b → buffer picker menu
    { mode = "n", keys = "<Leader>b", desc = "+Buffers" },
    -- Helix: space+/ → global search
    { mode = "n", keys = "<Leader>/", desc = "+Search" },
    -- Helix: space+s → symbol picker menu
    { mode = "n", keys = "<Leader>s", desc = "+Symbols" },
    -- Helix: space+d → diagnostics menu
    { mode = "n", keys = "<Leader>d", desc = "+Diagnostics" },
    -- Helix: space+g → version control
    { mode = "n", keys = "<Leader>g", desc = "+Git" },
    -- Helix: space+c → code actions (rename, format, actions)
    { mode = "n", keys = "<Leader>c", desc = "+Code" },
  },

  window = {
    delay = 300,
    config = {
      width = "auto",
    },
  },
})
