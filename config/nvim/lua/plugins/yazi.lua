return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- Helix: Ctrl-y → open yazi file picker
      { "<C-y>", "<cmd>Yazi<CR>", desc = "Open yazi" },
    },
    opts = {
      open_for_directories = false,
    },
  },
}
