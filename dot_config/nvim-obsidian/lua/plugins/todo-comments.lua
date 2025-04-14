return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
}
-- Using Lazy.nvim
-- return {
--     "folke/todo-comments.nvim",
--     dependencies = "nvim-lua/plenary.nvim",
--     opts = {
--       keywords = {
--         TODO = { icon = " ", color = "info", alt = { "TODO", "- [ ]" } },
--       },
--       search = {
--         pattern = [[ \-\s\[\s\] ]], -- matches "TODO" or "- [ ]"
--       },
--     },
-- }

-- return {
--   "folke/todo-comments.nvim",
--   dependencies = { "nvim-lua/plenary.nvim" },
--   lazy = false,
--   config = function()
-- 	require("todo-comments").setup({
--   		keywords = {
--     			CHECKBOX = {
--       				icon = "☐",
--       				color = "hint",
--       				alt = { "- [ ]", "* [ ]" },
--     			},
--   		},
--   		search = {
--     			pattern = [[- \[ \]]], -- ripgrep-compatible
--   			},
-- 	})
--     -- keymap to view checkbox todos in Trouble
--     vim.keymap.set("n", "<leader>xt", "<cmd>TodoTrouble keywords=CHECKBOX<cr>", { desc = "View [ ] todos in Trouble" })
--   end,
-- }
