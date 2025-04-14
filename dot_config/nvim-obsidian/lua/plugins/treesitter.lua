return {
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
}
