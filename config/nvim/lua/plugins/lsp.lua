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
      },
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
  {
    -- markdown-oxide is installed via nix, configure it directly
    "neovim/nvim-lspconfig",
    opts = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      require("lspconfig").markdown_oxide.setup({
        capabilities = capabilities,
      })
    end,
  },
}
