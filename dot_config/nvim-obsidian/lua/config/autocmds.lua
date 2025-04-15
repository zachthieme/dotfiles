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
		print("saved")
	end,
	desc = "Auto-save Markdown files on InsertLeave",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
	end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		local hl = vim.api.nvim_set_hl

		-- Headings
		hl(0, "@text.title.1.markdown", { fg = "#000000", bold = true })
		hl(0, "@text.title.2.markdown", { fg = "#222222", bold = true })
		hl(0, "@text.title.3.markdown", { fg = "#444444", bold = true })

		-- Bold & Italic
		hl(0, "@text.strong.markdown", { bold = true })
		hl(0, "@text.emphasis.markdown", { italic = true })

		-- Inline Code
		hl(0, "@text.literal.markdown_inline", { bg = "#f0f0f0", fg = "#111111" })

		-- Lists and bullets
		hl(0, "@punctuation.special.markdown", { fg = "#999999" })

		-- Links
		hl(0, "@text.uri.markdown_inline", { fg = "#0066cc", underline = true })

		-- Tags
		hl(0, "@tag.obsidian", { fg = "#005f5f", italic = true })

		-- Frontmatter
		hl(0, "ObsidianFrontmatter", { fg = "#888888", italic = true })
	end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		local hl = vim.api.nvim_set_hl

		hl(0, "ObsidianLink", { fg = "#0055aa", underline = true })
		hl(0, "ObsidianTag", { fg = "#005f5f", italic = true })
		hl(0, "ObsidianHighlightText", { bg = "#eeeedd", bold = true })

		-- Optional: disable conceal background "box" styling
		hl(0, "Conceal", { bg = "NONE", fg = "#888888" })
	end,
})
