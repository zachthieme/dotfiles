local home = vim.fn.expand("~/zettelkasten")

return {
  "renerocksai/telekasten.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-telekasten/calendar-vim" },
  config = function()
    local telekasten = require("telekasten")

    telekasten.setup({
      home = vim.fn.expand("~/zettelkasten"), -- your note directory
      template_new_daily = home .. "/" .. "templates/daily.md",
      -- you can add more options here
    })
    --
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "telekasten",
      callback = function()
        vim.api.nvim_buf_set_keymap(
          0,
          "n",
          "<CR>",
          ":lua require('telekasten').follow_link()<CR>",
          { noremap = true, silent = true }
        )
      end,
    })
    -- Only run if no files were passed to nvim
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        telekasten.goto_today()
      end)
    end
    vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>")
    vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
    vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>")
    vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>")
    vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
    vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>")
    vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>")
    vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>")
    vim.keymap.set("i", "[[", function()
      require("telekasten").insert_link()
    end, { desc = "Autocomplete Telekasten Link" })
    vim.keymap.set("n", "<leader>t", function()
      local line = vim.api.nvim_get_current_line()
      local date = os.date("%Y-%m-%d")
      if line:match("^%s*DONE") then
        local original = line:match("original:(todo)") or line:match("original:(today)")
        local restore = string.upper(original) or "TODO"
        line = line:gsub("^%s*DONE", restore, 1)
        line = line:gsub("%s*<!--.-%-%->", "")
      else
        local keyword = line:match("^%s*(TODO)") or line:match("^%s*(TODAY)")
        if keyword then
          line = line:gsub("^%s*" .. keyword, "DONE", 1)
          line = line .. " <!-- completed:" .. date .. " original:" .. string.lower(keyword) .. " -->"
        else
          line = "TODO " .. line
        end
      end
      vim.api.nvim_set_current_line(line)
    end, { desc = "Toggle TODO/TODAY ↔ DONE", noremap = true, silent = true })
  end,
}
