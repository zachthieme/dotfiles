return {
  "hrsh7th/nvim-cmp",
  ft = "mdw",
  opts = function(_, opts)
    -- You can set custom completion options here
    opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
      autocomplete = { "TextChanged" }, -- you can use InsertEnter too
      keyword_length = 2, -- characters typed before triggering
      debounce = 700, -- time in ms before triggering completion
    })
  end,
}
