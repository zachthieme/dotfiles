-- LSP keybindings — set on LspAttach so they only activate when a server is
-- connected. g-prefixed bindings mirror Helix's goto-mode.

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(event)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = desc })
    end

    -- Helix: gd → goto definition
    map("gd", vim.lsp.buf.definition, "Go to definition")
    -- Helix: gr → goto references
    map("gr", vim.lsp.buf.references, "Go to references")
    -- Helix: gy → goto type definition
    map("gy", vim.lsp.buf.type_definition, "Go to type definition")
    -- Helix: gD → goto declaration
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    -- Helix: K → hover docs
    map("K", vim.lsp.buf.hover, "Hover docs")

    -- Helix: space+c — code actions menu
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
  end,
})

-- Return empty table so lazy.nvim treats this as a valid spec
return {}
