-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set(
	"n",
	"<leader>wn",
	"<cmd>cd ~/Dropbox/vimwiki<cr><bar><cmd>VimwikiIndex<cr><bar><cmd>Calendar -view=year -split=vertical -width=27 -position=right<cr><bar><cmd>wincmd h<cr><bar><cmd>Trouble todo<cr>",
	{ desc = "Setup my notes environment." }
)
--
-- vim.keymap.set("n", "<leader>td", function()
-- 	local line = vim.api.nvim_get_current_line()
-- 	local date = os.date("%Y-%m-%d")
--
-- 	if line:match("^%s*TODO") then
-- 		-- Replace TODO with DONE and add completed date
-- 		line = line:gsub("TODO", "DONE", 1)
-- 		if not line:match("completed:%d%d%d%d%-%d%d%-%d%d") then
-- 			line = line .. " completed:" .. date
-- 		end
-- 	elseif line:match("^%s*DONE") then
-- 		-- Replace DONE with TODO and remove completed date
-- 		line = line:gsub("DONE", "TODO", 1)
-- 		line = line:gsub("%s+completed:%d%d%d%d%-%d%d%-%d%d", "")
-- 	end
--
-- 	vim.api.nvim_set_current_line(line)
-- end, { desc = "Toggle TODO/DONE", noremap = true, silent = true })
vim.keymap.set("n", "<leader>td", function()
	local line = vim.api.nvim_get_current_line()
	local date = os.date("%Y-%m-%d")

	if line:match("^%s*DONE") then
		-- Restore the original keyword (TODO or TODAY), defaulting to TODO
		local original = line:match("original:(TODO|TODAY)")
		local restore = original or "TODO"

		line = line:gsub("^%s*DONE", restore, 1)
		line = line:gsub("%s+completed:%d%d%d%d%-%d%d%-%d%d", "")
		line = line:gsub("%s+original:(TODO|TODAY)", "")
	elseif line:match("^%s*TODO") or line:match("^%s*TODAY") then
		local keyword = line:match("^%s*(TODO|TODAY)")

		line = line:gsub("^%s*" .. keyword, "DONE", 1)
		if not line:match("completed:%d%d%d%d%-%d%d%-%d%d") then
			line = line .. " completed:" .. date .. " original:" .. keyword
		end
	end

	vim.api.nvim_set_current_line(line)
end, { desc = "Toggle TODO/TODAY ↔ DONE", noremap = true, silent = true })
