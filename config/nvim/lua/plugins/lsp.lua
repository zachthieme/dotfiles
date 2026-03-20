return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "gopls",
        "rust_analyzer",
        "ts_ls",
        "bashls",
        "marksman",
      },
      -- Catch-all handler: every server in ensure_installed gets default setup
      -- with blink.cmp capabilities. No per-server config needed.
      handlers = {
        function(server_name)
          local capabilities = require("blink.cmp").get_lsp_capabilities()
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
          })
        end,
      },
    },
  },
}
