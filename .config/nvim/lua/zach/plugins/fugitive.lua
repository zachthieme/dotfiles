return {
  "tpope/vim-fugitive",
  config = function()
    local keymap = vim.keymap
    keymap.set(
      "n",
      "<leader>q",
      '<cmd>:Gwrite <BAR> Git commit -m "updated doc" <BAR> Git push <BAR> q<cr>',
      { desc = "Push to github" }
    )
  end,
}
