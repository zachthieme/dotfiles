return
    {
        'bluz71/vim-nightfly-colors',
        name = "nightfly",
        lazy = false, -- Ennure the plugin is loaded immediately
        priority = 1000, -- Load before other plugins
        config = function()
            vim.opt.termguicolors = true
            vim.cmd [[colorscheme nightfly]]
        end,
    }
