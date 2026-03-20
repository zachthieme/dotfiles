-- Catppuccin (mocha) — warm dark theme with good contrast
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    flavour = "mocha",
    no_italic = true,
    integrations = {
      blink_cmp = true,
      mason = true,
      mini = { enabled = true },
      snacks = true,
      treesitter = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
