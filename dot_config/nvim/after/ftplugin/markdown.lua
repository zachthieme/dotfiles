local set = vim.opt_local

-- enable pencil for markdown files
vim.cmd("call pencil#init()")

-- make sure that o/O don't prepend comments
set.formatoptions:remove("o")

-- enable spell checking
vim.opt.spelllang = "en_us"
vim.opt.spell = true

-- vim.cmd("<leader>wn")
vim.cmd("<cmd>topleft vs<BAR>vertical resize 50<cr><BAR><cmd>TZMinimalist<cr><BAR><cmd>norm Gzt<cr>")
