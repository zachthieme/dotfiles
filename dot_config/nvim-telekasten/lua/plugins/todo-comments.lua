return {
  "folke/todo-comments.nvim",
  opts = {
    highlight = {
      pattern = [[.*(KEYWORDS)[:]?\s*]],
    },
    search = {
      pattern = [[\b(KEYWORDS):?]],
    },
    keywords = {
      TODO = {
        alt = { "TODO", "TODAY", "DELEGATED" },
      },
    },
  },
}
