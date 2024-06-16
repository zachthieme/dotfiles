return {
  "preservim/vim-pencil",
  init = function()
    vim.g["pencil#wrapModeDefault"] = "hard"
  end,
  config = function()
    local keymap = vim.keymap
    keymap.set(
      "n",
      "<leader>vs",
      "<cmd>:topleft vs <BAR> vertical resize 50 <BAR> norm Gzt<cr>",
      { desc = "create split to the left" }
    )
  end,
}
