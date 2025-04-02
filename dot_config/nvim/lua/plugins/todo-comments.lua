return {
  "folke/todo-comments.nvim",
  opts = {
    highlight = {
      -- This will highlight TODO or TODO: — colon is optional
      pattern = [[.*<(KEYWORDS)[:]?\s*]],
    },
    search = {
      -- This will match TODO or TODO: in search and Trouble
      pattern = [[\b(KEYWORDS):?]],
    },
  },
}
