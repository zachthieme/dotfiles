return {
  {
    'bluz71/vim-nightfly-colors',
    lazy = false, -- Optional: ensures the theme is loaded immediately
    priority = 1000, -- Optional: ensures the theme is loaded first
    config = function()
      -- vim.cmd([[colorscheme nightfly]])
      vim.cmd('colorscheme nightfly')
    end,
  },
}
