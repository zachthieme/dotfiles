return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme catppuccin]])
      require("catppuccin").setup({
        integrations = {
          alpha = true,
          cmp = true,
          dashboard = true,
          flash = true,
          gitsigns = true,
          harpoon = true,
          leap = true,
          lsp_trouble = true,
          markdown = true,
          mason = true,
          noice = true,
          notify = true,
          nvimtree = true,
          telescope = {
            enabled = true,
          },
          treesitter = true,
          which_key = true,
          -- mini = {
          --     enabled = true,
          --     indentscope_color = "",
          -- },
        },
      })
    end,
  },
}
