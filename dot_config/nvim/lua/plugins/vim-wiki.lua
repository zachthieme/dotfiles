return {
  {
    "vimwiki/vimwiki",
    init = function()
      vim.g.vimwiki_list = {
        {
          path = "~/Dropbox/vimwiki",
          syntax = "markdown",
          ext = ".mdw",
        },
      }
    end,
    config = function()
      -- Keymaps after Vimwiki loads and filetype is correct
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "vimwiki",
        callback = function()
          -- Use command instead of <Plug> mapping for safety
          vim.keymap.set("n", "<CR>", ":VimwikiFollowLink<CR>", { buffer = true, silent = true })
          vim.keymap.set("n", "<BS>", ":VimwikiGoBackLink<CR>", { buffer = true, silent = true })
        end,
      })
    end,
  },
  {
    "itchyny/calendar.vim",
    cmd = { "Calendar" },
    config = function()
      -- Optional: open diary note from calendar
      vim.g.calendar_diary = "~/vimwiki/diary"
      vim.g.calendar_monday = 1 -- week starts on Monday
      vim.g.calendar_mark = "left" -- diary indicators on the left
    end,
  },
}
