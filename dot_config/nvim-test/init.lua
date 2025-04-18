-- Why we are here:
-- I wanted to start using vim for my writing and my note taking but wanted to have some of the convienenve of the personal knowledge management systems i've been using for years (mostly roam research and logseq).
-- I started with Lazyvim and added obsidian.nvim but strange things were happening. autocomplete didn't always work and i couldn't figure out the configurations i needed to keep it working consistently.
-- So i started with kickstart and built a clean and new obsidian config and added a ton of customization - and then my cursor started jumping around when i would save, the concealer sometimes got stuck to 3 (not 2 like i need), and sometimes the concealer would just stop working.
-- At my wits end i grabbed and neutered a version of kickstart.  Stripped it to the bar minimum and have been building back slowly...below is my story.

-- 1. Kept kickstart defaults for vim.opts and adjusted a few
--
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false
vim.opt.conceallevel = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
-- 13. noticed that hyphens were appearing between words and noticed that vim.opt.list was true - deleted
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.confirm = true

-- 2. kept minimal set of keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- 3. Kept one function
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- 8. added an autocommand to skin obsidian in the habamax style.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.cmd("highlight markdownH1 guifg=#ff8700")
		vim.cmd("highlight markdownH2 guifg=#d7af5f")
		vim.cmd("highlight markdownH3 guifg=#87af87")
	end,
})

-- part of 17
vim.api.nvim_set_hl(0, "ObsidianCancelled", {
	strikethrough = true,
	fg = "#888888", -- optional: faded grey
})

-- 4. Kept one autocmd
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- 14. adding autocmds to enable softwrap and gj/gk for markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "obsidian" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true

		-- Visual line navigation
		local opts = { buffer = true, silent = true }
		vim.keymap.set("n", "j", "gj", opts)
		vim.keymap.set("n", "k", "gk", opts)
	end,
})

-- 15. adding autocmds to change cwd and make sure we are in the work vault

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.cmd("cd ~/Dropbox/vaults/work")
		end
	end,
})

-- part of 10
vim.keymap.set("i", "/d", function()
	vim.schedule(function()
		-- Prompt the user for natural language date
		vim.ui.input({ prompt = "Enter natural date (e.g. next Tuesday): " }, function(input)
			if input and input ~= "" then
				local parsed = require("naturally").parse_date(input)
				if parsed then
					-- Insert the parsed date
					vim.api.nvim_feedkeys(parsed, "i", true)
				else
					vim.notify("Could not parse: " .. input, vim.log.levels.WARN)
				end
			end
		end)
	end)
end, { expr = false, desc = "Insert parsed natural date on /d" })

-- 5. Removed all configs in lazy and deleted custom/ and kickstart/
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- 6. Added a small version of my obsidian.nvim config
	-- 12. refactor of obsidian plugin and add some autocommands and helper functions
	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		lazy = false,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
			"nvim-telescope/telescope.nvim",
			"nvim-telekasten/calendar-vim",
		},
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},
		opts = {
			wiki_link_func = "use_alias_only",
			markdown_link_func = "use_alias_only",
			disable_frontmatter = true, --{ enabled = true },

			note_id_func = function(title)
				-- If there's a title, slugify it; otherwise, use a timestamp
				if title ~= nil then
					return title:gsub(" ", "-"):gsub("[^A-Za-z0-9%-]", ""):lower()
				else
					return tostring(os.time()) -- fallback to timestamp if no title
				end
			end,
			-- 17. custom icons and states that should be a single character width
			-- TODO figure out why the custom icons don't seem to be working
			ui = {
				enable = true,
				update_debounce = 200,
				todo = {
					-- format: [marker] = { icon = "symbol", hl_group = "HighlightGroup" }
					[" "] = { icon = "○", hl_group = "ObsidianTodo" },
					["x"] = { icon = "✓", hl_group = "ObsidianDone" },
					[">"] = { icon = "→", hl_group = "ObsidianDelegated" },
					["c"] = { icon = "✗", hl_group = "ObsidianCancelled", hl_mode = "line" },
				},
			},
			workspaces = {
				{
					name = "work",
					path = "~/Dropbox/vaults/work",
				},
				{
					name = "personal",
					path = "~/Dropbox/vaults/personal",
				},
			},

			templates = {
				folder = "~/Dropbox/vaults/work/templates",
			},

			daily_notes = {
				template = "~/Dropbox/vaults/work/templates/daily.md",
			},
		},
		config = function(_, opts)
			require("obsidian").setup(opts)

			-- Function to toggle quick fix and key binding
			local function toggle_quickfix()
				for _, win in ipairs(vim.fn.getwininfo()) do
					if win.quickfix == 1 then
						vim.cmd("cclose")
						return
					end
				end
				vim.cmd("copen")
			end

			vim.api.nvim_create_user_command("CToggle", toggle_quickfix, { desc = "Toggle quickfix list" })

			-- User command to find markdown todo's and add hem to the quick fix list
			vim.api.nvim_create_user_command("MarkdownTodos", function()
				vim.fn.setqflist({})
				vim.cmd('cexpr system(\'rg -n --no-heading "^\\\\s*\\\\W\\\\s\\\\[ \\\\]" --glob "**/*.md"\')')
			end, { desc = "Update quickfix with markdown checkboxes" })

			-- 20. commenting this out to see if it stops the strange movement
			-- Update markdown todo quickfix list when saving a buffer
			-- vim.api.nvim_create_autocmd("BufWritePost", {
			-- 	pattern = "*.md",
			-- 	callback = function()
			-- 		vim.cmd("MarkdownTodos")
			-- 	end,
			-- 	desc = "Update markdown checkbox quickfix list on save",
			-- })

			-- Run :ObsidianToday once Neovim starts and Obsidian is loaded
			vim.api.nvim_create_autocmd("VimEnter", {
				once = true,
				callback = function()
					vim.schedule(function()
						vim.cmd("ObsidianToday")
						vim.cmd("MarkdownTodos")
					end)
				end,
			})
			-- 	require("lazy").load({ plugins = { "which-key.nvim" } })
			-- 	local wk = require("which-key")
			--
			-- 	wk.add({
			-- 		{ "<leader>n", group = "notes" },
			-- 		{ "<leader>nt", "<cmd>ObsidianToday<CR>", desc = "Today’s Note", mode = "n" },
			-- 		{ "<leader>ny", "<cmd>ObsidianYesterday<CR>", desc = "Yesterday’s Note", mode = "n" },
			-- 		{ "<leader>nw", "<cmd>ObsidianThisWeek<CR>", desc = "This Week’s Note", mode = "n" },
			-- 		{ "<leader>nn", "<cmd>ObsidianNew<CR>", desc = "New Note", mode = "n" },
			-- 		{ "<leader>nf", "<cmd>ObsidianSearch<CR>", desc = "Search Vault", mode = "n" },
			-- 		{ "<leader>nb", "<cmd>ObsidianBacklinks<CR>", desc = "Backlinks", mode = "n" },
			-- 		{ "<leader>nl", "<cmd>ObsidianFollowLink<CR>", desc = "Follow Link", mode = "n" },
			-- 		{ "<leader>no", "<cmd>ObsidianOpen<CR>", desc = "Open in Obsidian App", mode = "n" },
			-- 		{ "<leader>nm", "<cmd>ObsidianMetadata<CR>", desc = "Show Metadata", mode = "n" },
			-- 		{ "<leader>ns", "<cmd>ObsidianSwitch<CR>", desc = "Switch Workspace", mode = "n" },
			-- 	})
		end,
	},
	-- 7. Added a custom config for nvim-cmp
	{
		-- 11. commented out things i didn't need may delete at a later date
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- "hrsh7th/cmp-nvim-lsp", -- LSP source
			"hrsh7th/cmp-buffer", -- Buffer source
			"hrsh7th/cmp-path", -- File path source
			-- 9. Added luasnip in the hopes of getting list completion
			--  it did not work - but i got date completion
			-- "L3MON4D3/LuaSnip", -- Snippet engine
			-- "saadparwaiz1/cmp_luasnip", -- LuaSnip source
			"echasnovski/mini.snippets",
			"abeldekat/cmp-mini-snippets",
			-- "rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			-- require("luasnip.loaders.from_vscode").lazy_load()
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),
				}),
				sources = cmp.config.sources({
					-- { name = "nvim_lsp" },
					-- { name = "luasnip" },
					{ name = "buffer" },
					-- { name = "path" },
					{ name = "natdat" },
				}),
			})
		end,
	},
	-- 10. wanted to add fuzzy date completion for due dates
	{ "Gelio/cmp-natdat", config = true },
	-- 16. added noice
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
	-- 19 on work computer noticed that the cursor jumping on save was back. need to see if it's just my work computer
	--  validated it happens on my linux computer in the cloud!!!
	-- 18 added a lualine that is set to be more for writers
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				theme = "auto", -- lualine picks up habamax from your colorscheme
				icons_enabled = true,
				globalstatus = true,
				component_separators = "",
				section_separators = "",
				disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "filetype" },
				lualine_y = {},
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		},
	},
})
