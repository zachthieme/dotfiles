-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- In your config (e.g., ~/.config/nvim/lua/config/init.lua or similar)

-- failsafe to ensure that anything in a vimwiki directory has filetype set to vimwiki
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.mdw",
  callback = function()
    vim.bo.filetype = "vimwiki"
    vim.opt.wrap = true
  end,
})
