return {
  "folke/snacks.nvim",
  priority = 900,
  opts = {
    picker = { enabled = true },
    notifier = { enabled = true },
    lazygit = { enabled = true },
  },
  keys = {
    -- Helix: space+f — file picker (find files, recent, grep project root)
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Find in project" },

    -- Helix: space+b — buffer picker
    { "<leader>bb", function() Snacks.picker.buffers() end, desc = "Buffer list" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer" },

    -- Helix: space+/ — global search (live grep, grep word)
    { "<leader>/g", function() Snacks.picker.grep() end, desc = "Live grep" },
    { "<leader>/w", function() Snacks.picker.grep_word() end, desc = "Grep word under cursor" },

    -- Helix: space+s — symbol picker (document and workspace symbols)
    { "<leader>sd", function() Snacks.picker.lsp_symbols() end, desc = "Document symbols" },
    { "<leader>sw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols" },

    -- Helix: space+d — diagnostics
    { "<leader>df", function() vim.diagnostic.open_float() end, desc = "Open float" },
    { "<leader>dn", function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
    { "<leader>dp", function() vim.diagnostic.goto_prev() end, desc = "Prev diagnostic" },
    { "<leader>dl", function() Snacks.picker.diagnostics() end, desc = "List all" },

    -- Helix: space+g — version control
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
  },
}
