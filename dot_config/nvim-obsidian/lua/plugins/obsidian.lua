return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = false,
  ft = "markdown",
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "nvim-telekasten/calendar-vim",
  },
  opts = {
    note_id_func = function(title)
      -- If there's a title, slugify it; otherwise, use a timestamp
      if title ~= nil then
        return title:gsub(" ", "-"):gsub("[^A-Za-z0-9%-]", ""):lower()
      else
        return tostring(os.time()) -- fallback to timestamp if no title
      end
    end,
    wiki_link_func = "use_alias_only",
    markdown_link_func = "use_alias_only",
    disable_frontmatter = true, --{ enabled = true },
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
      folder = "~/.config/nvim-obsidian/templates",
    },

    daily_notes = {
      template = "~/.config/nvim-obsidian/templates/daily.md",
    },
    ui = {
      enable = true,  -- set to false to disable all additional syntax features
    update_debounce = 200,  -- update delay after a text change (in milliseconds)
    max_file_length = 5000,  -- disable UI features for files with more than this many lines
    -- Define how various check-boxes are displayed
    checkboxes = {
      [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
      ["x"] = { char = "", hl_group = "ObsidianDone" },
      [">"] = { char = "", hl_group = "ObsidianRightArrow" },
      ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
    },
  },
  completion = {
    nvim_cmp = true,
    min_chars = 2,
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    local function toggle_quickfix()
      for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
          vim.cmd("cclose")
          return
        end
      end
      vim.cmd("copen")
    end

    -- vim.api.nvim_create_autocmd("BufReadPost", {
    --   pattern = "*.md",
    --   callback = function()
    --     vim.api.nvim_command("normal! G")
    --   end,
    -- })

    vim.api.nvim_create_user_command("CToggle", toggle_quickfix, { desc = "Toggle quickfix list" })

    -- lua/plugins/markdown-todos.lua or any config file
    vim.api.nvim_create_user_command("MarkdownTodos", function()
      vim.fn.setqflist({})
      vim.cmd('cexpr system(\'rg -n --no-heading "^\\\\s*\\\\W\\\\s\\\\[ \\\\]" --glob "**/*.md"\')')
      -- vim.cmd('cexpr system(\'rg -n --no-heading "^\\\\s*(\\\\*|-)\\\\s\\\\[ \\\\]" --glob "**/*.md"\')')
      -- vim.cmd("CToggle")
    end, { desc = "Update quickfix with markdown checkboxes" })

    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.md",
      callback = function()
        vim.cmd("MarkdownTodos")
      end,
      desc = "Update markdown checkbox quickfix list on save",
    })
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
    require("lazy").load({ plugins = { "which-key.nvim" } })
    local wk = require("which-key")

    wk.add({
      { "<leader>n", group = "notes" },
      { "<leader>nt", "<cmd>ObsidianToday<CR>", desc = "Today’s Note", mode = "n" },
      { "<leader>ny", "<cmd>ObsidianYesterday<CR>", desc = "Yesterday’s Note", mode = "n" },
      { "<leader>nw", "<cmd>ObsidianThisWeek<CR>", desc = "This Week’s Note", mode = "n" },
      { "<leader>nn", "<cmd>ObsidianNew<CR>", desc = "New Note", mode = "n" },
      { "<leader>nf", "<cmd>ObsidianSearch<CR>", desc = "Search Vault", mode = "n" },
      { "<leader>nb", "<cmd>ObsidianBacklinks<CR>", desc = "Backlinks", mode = "n" },
      { "<leader>nl", "<cmd>ObsidianFollowLink<CR>", desc = "Follow Link", mode = "n" },
      { "<leader>no", "<cmd>ObsidianOpen<CR>", desc = "Open in Obsidian App", mode = "n" },
      { "<leader>nm", "<cmd>ObsidianMetadata<CR>", desc = "Show Metadata", mode = "n" },
      { "<leader>ns", "<cmd>ObsidianSwitch<CR>", desc = "Switch Workspace", mode = "n" },
    })
  end,
}
