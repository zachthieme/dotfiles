return {
  "echasnovski/mini.nvim",
  config = function()
    -- Surround: Helix uses ms/md/mr for surround add/delete/replace
    require("mini.surround").setup()

    -- Auto-pairs: Helix doesn't have this, but it's essential for Neovim
    require("mini.pairs").setup()

    -- Icons: used by statusline and other plugins
    require("mini.icons").setup()

    -- Statusline: Helix has a built-in statusline; mini.statusline replicates it
    require("mini.statusline").setup({
      use_icons = true,
    })

    -- Clue: Helix's space menu — shows available keybindings after leader press.
    -- Configured in plugins/clue.lua for readability.
    require("config.clue-setup")
  end,
}
