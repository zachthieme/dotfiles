-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set(
  "n",
  "<leader>wn",
  "<cmd>VimwikiIndex<cr><bar><cmd>Calendar -view=year -split=vertical -width=27 -position=right<cr><bar><cmd>Trouble todo<cr>",
  { desc = "Setup my notes environment." }
)
