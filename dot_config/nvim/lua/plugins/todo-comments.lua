return {
  "folke/todo-comments.nvim",
  opts = {
    highlight = {
      pattern = [[.*<(KEYWORDS)[:]?\s*]],
    },
    search = {
      -- This will match TODO or TODO: in search and Trouble
      pattern = [[\b(KEYWORDS):?]],
    },
    keywords = {
      TODO = {
        alt = { "TODO", "TODAY", "DELEGATED" },
      },
    },
  },
}
