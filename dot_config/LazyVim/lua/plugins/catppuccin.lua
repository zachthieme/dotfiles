return { "catppuccin/nvim", name = "catppuccin", priority = 1000 }

require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"


