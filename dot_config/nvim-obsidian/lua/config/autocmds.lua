-- set default working directory
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   pattern = vim.fn.expand("~/Dropbox/vaults/work") .. "/**",
--   callback = function()
--     vim.cmd.cd(vim.fn.expand("~/Dropbox/vaults/work"))
--   end,
-- })
--
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("cd ~/Dropbox/vaults/work")
    end
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*.md",
  callback = function()
    vim.cmd("silent! write")
  end,
  desc = "Auto-save Markdown files on InsertLeave",
})
