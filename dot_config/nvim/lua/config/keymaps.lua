-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set(
	"n",
	"<leader>wn",
	"<cmd>cd ~/Dropbox/vimwiki<cr><bar><cmd>VimwikiIndex<cr><bar><cmd>Calendar -view=year -split=vertical -width=27 -position=right<cr><bar><cmd>wincmd h<cr><bar><cmd>Trouble todo<cr>",
	{ desc = "Setup my notes environment." }
)

vim.keymap.set("n", "<leader>td", function()
	local line = vim.api.nvim_get_current_line()
	local date = os.date("%Y-%m-%d")

	if line:match("^%s*DONE") then
		-- Restore the original keyword (TODO or TODAY), defaulting to TODO
		local original = line:match("original:(TODO)") or line:match("original:(TODAY)")
		local restore = original or "TODO"

		-- Replace DONE with the original keyword
		line = line:gsub("^%s*DONE", restore, 1)
		-- Remove the metadata (completed date and original tag)
		line = line:gsub("%s*completed:*", "")
		line = line:gsub("%s*original:(TODO|TODAY)", "")
	else
		-- Check for TODO or TODAY keyword at line start
		local keyword = line:match("^%s*(TODO)") or line:match("^%s*(TODAY)")
		if keyword then
			-- Replace keyword with DONE
			line = line:gsub("^%s*" .. keyword, "DONE", 1)
			-- Add completed date and original keyword
			line = line .. " completed:" .. date .. " original:" .. keyword
		end
	end

	vim.api.nvim_set_current_line(line)
end, { desc = "Toggle TODO/TODAY ↔ DONE", noremap = true, silent = true })
