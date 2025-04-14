
-- set default working directory
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = vim.fn.expand("~/Dropbox/vaults/work") .. "/**",
  callback = function()
    vim.cmd.cd(vim.fn.expand("~/Dropbox/vaults/work"))
  end,
})


