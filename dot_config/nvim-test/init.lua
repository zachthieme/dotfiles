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
-- added as part of 20
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

-- 21. autofold concealed markdown links
function MarkdownFoldExpr(lnum)
  local line = vim.fn.getline(lnum)
  if line:match("%[[^%]]+%]%([^)]+%)") then
    return 1
  end
  return 0
end

-- Autocmd to enable folding for markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.MarkdownFoldExpr(v:lnum)"
  end,
})

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
-- 22. removing softwrap for now - and added it backi
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

-- 27. testing a single function to start today and change cwd
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
  -- 7. Added a custom config for nvim-cmp
  {
    -- 11. commented out things i didn't need may delete at a later date
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
  -- 23. Added Snipe
  {
    "leath-dub/snipe.nvim",
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
  -- 24. which key
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
  -- 25. added autosave
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

  -- 19 on work computer noticed that the cursor jumping on save was back. need to see if it's just my work computer
  --  validated it happens on my linux computer in the cloud!!!
  -- 18 added a lualine that is set to be more for writers
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
})
