return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme catppuccin]])
    end,

    require("catppuccin").setup({
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        -- mini = {
        --     enabled = true,
        --     indentscope_color = "",
        -- },
      },
    }),
  },
}
