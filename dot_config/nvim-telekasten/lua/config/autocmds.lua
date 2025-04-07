-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = vim.fn.expand("~/zettelkasten") .. "/**",
  callback = function()
    vim.cmd.cd(vim.fn.expand("~/zettelkasten"))
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "telekasten",
  callback = function()
    vim.b.minipairs_disable = true
  end,
})

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  callback = function()
    vim.cmd("highlight CursorLine guibg=#4c2c2c") -- Insert mode color
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  callback = function()
    vim.cmd("highlight CursorLine guibg=#3c4048") -- Normal mode color
  end,
})

vim.api.nvim_create_autocmd({ "VisualEnter" }, {
  callback = function()
    vim.cmd("highlight CursorLine guibg=#524f67") -- Visual mode color
  end,
})

vim.api.nvim_create_autocmd({ "VisualLeave" }, {
  callback = function()
    vim.cmd("highlight CursorLine guibg=#3c4048") -- Reset to Normal mode color
  end,
})
