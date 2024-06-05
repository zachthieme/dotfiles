return {
  "preservim/vim-pencil",
  init = function()
    vim.g["pencil#wrapModeDefault"] = "soft"
  end,
  config = function()
    local keymap = vim.keymap
    keymap.set(
      "n",
      "<leader>vs",
      "<cmd>:topleft vs <BAR> vertical resize 50<cr>",
      { desc = "create split to the left" }
    )
  end,
}
