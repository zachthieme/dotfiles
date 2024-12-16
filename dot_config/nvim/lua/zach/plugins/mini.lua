 return {
  "echasnovski/mini.nvim",
  version = "*", -- Use the latest stable version
  config = function()
    -- Enable mini.nvim modules
    require("mini.ai").setup()
    require('mini.cursorword').setup()
	  require('mini.comment').setup()
    require('mini.surround').setup()
    require('mini.align').setup()
  end,
}
