vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false
vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc"
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
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.confirm = true

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("i", "<M-BS>", "<C-w>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>z", ":lua Snacks.zen()<CR>", { desc = "Toggle Zen mode" })

-- Track the CalendarVR window
local calendar_win_id = nil

vim.keymap.set("n", "<leader>c", function()
	if calendar_win_id and vim.api.nvim_win_is_valid(calendar_win_id) then
		vim.api.nvim_win_close(calendar_win_id, true)
		calendar_win_id = nil
		return
	end

	-- Launch CalendarVR
	vim.cmd("CalendarVR")

	-- Defer to allow the window to open
	vim.defer_fn(function()
		local win = vim.api.nvim_get_current_win()
		calendar_win_id = win

		-- Set clean UI (use vim.api.nvim_win_set_option for window options)
		vim.api.nvim_set_option_value("number", false, { scope = "local", win = win })
		vim.api.nvim_set_option_value("relativenumber", false, { scope = "local", win = win })
		vim.api.nvim_set_option_value("signcolumn", "no", { scope = "local", win = win })
		vim.api.nvim_set_option_value("foldcolumn", "0", { scope = "local", win = win })
	end, 100)
end, { desc = "Toggle CalendarVR with clean view" })

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- autofold concealed markdown links
function MarkdownFoldExpr(lnum)
	local line = vim.fn.getline(lnum)
	if line:match("%[[^%]]+%]%([^)]+%)") then
		return 1
	end
	return 0
end

-- remove trailing spaces
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.md", "*.lua" },
	callback = function()
		vim.cmd([[silent! %s/\s\+$//e]])
	end,
})

-- Autocmd to enable folding for markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "v:lua.MarkdownFoldExpr(v:lnum)"
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

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

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() > 0 then
			return
		end

		vim.cmd("cd ~/Dropbox/vaults/work")
		vim.cmd("ObsidianToday")
		vim.cmd("MarkdownTodos")
	end,
})

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
	{
		"epwalsh/obsidian.nvim",
		version = "*",
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
			ui = {
				enable = true,
				update_debounce = 200,
				checkboxes = {
					[" "] = { order = 1, char = "○", hl_group = "ObsidianTodo" },
					["x"] = { order = 2, char = "✓", hl_group = "ObsidianDone" },
					[">"] = { order = 3, char = "→", hl_group = "ObsidianRightArrow" },
					["~"] = { order = 4, char = "✗", hl_group = "ObsidianCancelled", hl_mode = "line" },
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

			vim.api.nvim_create_user_command("MarkdownTodos", function()
				-- Get today's date in ISO format
				local today = os.date("%Y-%m-%d")

				-- Run ripgrep and capture all markdown todos with optional due tags
				local results = vim.fn.systemlist('rg -n --no-heading "^\\\\s*\\\\W\\\\s\\\\[ \\\\]" --glob "**/*.md"')

				local filtered = {}
				for _, line in ipairs(results) do
					local due = string.match(line, "@due:(%d%d%d%d%-%d%d%-%d%d)")
					if due == nil or due <= today then
						table.insert(filtered, line)
					end
				end

				vim.fn.setqflist({}, " ", { title = "Markdown Todos (due today or earlier)", lines = filtered })
			end, { desc = "Update quickfix with markdown checkboxes due today or earlier" })

			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = "*.md",
				callback = function()
					local win = vim.api.nvim_get_current_win()
					local buf = vim.api.nvim_get_current_buf()

					-- Get cursor position safely
					local pos = vim.api.nvim_win_get_cursor(win)
					local saved_row = pos[1]
					local saved_col = pos[2]

					vim.schedule(function()
						-- Run the update
						pcall(function()
							vim.cmd("silent! MarkdownTodos")
						end)

						if vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(buf) then
							-- restore window/buffer focus
							vim.api.nvim_set_current_win(win)
							vim.api.nvim_win_set_buf(win, buf)

							-- Get actual line length (since it may be concealed/modified)
							local line = vim.api.nvim_buf_get_lines(buf, saved_row - 1, saved_row, false)[1] or ""
							local clipped_col = math.min(saved_col, #line)

							-- Try setting the cursor, fallback to start of line
							pcall(vim.api.nvim_win_set_cursor, win, { saved_row, clipped_col })
						end
					end)
				end,
				desc = "Update markdown checkbox quickfix list on save (with cursor restore)",
			})
			require("lazy").load({ plugins = { "which-key.nvim" } })
			local wk = require("which-key")

			wk.add({
				{ "<leader>n", group = "notes" },
				{ "<leader>t", "<cmd>ObsidianToday<CR>", desc = "Today’s Note", mode = "n" },
				{ "<leader>y", "<cmd>ObsidianYesterday<CR>", desc = "Yesterday’s Note", mode = "n" },
				{ "<leader>nw", "<cmd>ObsidianThisWeek<CR>", desc = "This Week’s Note", mode = "n" },
				{ "<leader>nn", "<cmd>ObsidianNew<CR>", desc = "New Note", mode = "n" },
				{ "<leader>s", "<cmd>ObsidianSearch<CR>", desc = "Search Vault", mode = "n" },
				{ "<leader>nb", "<cmd>ObsidianBacklinks<CR>", desc = "Backlinks", mode = "n" },
				{ "<leader>ns", "<cmd>ObsidianSwitch<CR>", desc = "Switch Workspace", mode = "n" },
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer", -- Buffer source
			"hrsh7th/cmp-path", -- File path source
			"echasnovski/mini.snippets",
			"abeldekat/cmp-mini-snippets",
		},
		config = function()
			local cmp = require("cmp")
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
					{ name = "buffer" },
					{ name = "natdat" },
				}),
			})
		end,
	},
	{ "Gelio/cmp-natdat", config = true, lazy = false },
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
	{
		"leath-dub/snipe.nvim",
		lazy = false,
		keys = {
			{
				"gb",
				function()
					require("snipe").open_buffer_menu()
				end,
				desc = "Open Snipe buffer menu",
			},
		},
		opts = {},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	{
		"pocco81/auto-save.nvim",
		version = "*",
		config = function()
			require("auto-save").setup({
				enabled = true,
				execution_message = {
					enabled = false,
				},
				trigger_events = { "InsertLeave", "TextChanged" },
				condition = function(buf)
					local ft = vim.bo[buf].filetype
					return ft ~= "" and ft ~= "help" and vim.bo[buf].modifiable
				end,
				write_all_buffers = false,
			})
		end,
	},

	{
		"echasnovski/mini.nvim",
		version = "*", -- Use the latest stable version
		config = function()
			-- Enable mini.nvim modules
			require("mini.ai").setup()
			require("mini.align").setup()
			require("mini.cursorword").setup()
			require("mini.surround").setup()
			require("mini.trailspace").setup()
		end,
	},

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			toggle = { enabled = true },
			zen = { enabled = true },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate", -- auto-update parsers on install
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"markdown",
					"markdown_inline",
					"bash",
					"json",
					"yaml",
				},
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
				},
			})
		end,
	},
	{
		"ggandor/leap.nvim",
		enabled = true,
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "Leap Forward to" },
			{ "S", mode = { "n", "x", "o" }, desc = "Leap Backward to" },
			{ "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" },
		},
		config = function(_, opts)
			local leap = require("leap")
			for k, v in pairs(opts) do
				leap.opts[k] = v
			end
			leap.add_default_mappings(true)
			vim.keymap.del({ "x", "o" }, "x")
			vim.keymap.del({ "x", "o" }, "X")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				theme = "auto",
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
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				overrides = function(colors)
					local theme = colors.theme
					return {
						-- Markdown Header Colors
						["@markup.heading.1.markdown"] = { fg = theme.syn.number, bold = true },
						["@markup.heading.2.markdown"] = { fg = theme.syn.constant, bold = true },
						["@markup.heading.3.markdown"] = { fg = theme.syn.identifier, bold = true },
						["@markup.heading.4.markdown"] = { fg = theme.syn.statement, bold = true },
						["@markup.heading.5.markdown"] = { fg = theme.syn.special, bold = true },
						["@markup.heading.6.markdown"] = { fg = theme.syn.comment, bold = true },
					}
				end,
			})
			vim.cmd("colorscheme kanagawa")
		end,
	},
})
