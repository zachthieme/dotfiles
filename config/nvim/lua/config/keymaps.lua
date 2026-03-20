local map = vim.keymap.set

-- Clear search highlight (Helix: Escape clears selection)
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Helix: Alt-j/Alt-k — move lines up/down
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Helix: space+t — toggle task syntax (cycle: "- " → "- [ ] " → "- ")
local function toggle_task_syntax()
  local line = vim.api.nvim_get_current_line()
  local new
  if line:match("^(%s*)%- %[.%] ") then
    new = line:gsub("^(%s*)%- %[.%] ", "%1- ")
  elseif line:match("^(%s*)%- ") then
    new = line:gsub("^(%s*)%- ", "%1- [ ] ")
  else
    return
  end
  vim.api.nvim_set_current_line(new)
end
map({ "n", "v" }, "<leader>t", toggle_task_syntax, { desc = "Toggle task syntax" })

-- Helix: space+x — toggle task checked/unchecked with @completed date
local function toggle_task_check()
  local line = vim.api.nvim_get_current_line()
  local new
  if line:match("^(%s*)%- %[ %] ") then
    local cleaned = line:gsub(" *@completed%(%d%d%d%d%-%d%d%-%d%d%)", "")
    new = cleaned:gsub("^(%s*)%- %[ %] ", "%1- [x] ") .. " @completed(" .. os.date("%Y-%m-%d") .. ")"
  elseif line:match("^(%s*)%- %[[xX]%] ") then
    new = line:gsub("^(%s*)%- %[[xX]%] ", "%1- [ ] ")
    new = new:gsub(" *@completed%(%d%d%d%d%-%d%d%-%d%d%)", "")
  else
    return
  end
  vim.api.nvim_set_current_line(new)
end
map({ "n", "v" }, "<leader>x", toggle_task_check, { desc = "Toggle task check" })

-- Helix: space+T — insert pike output scoped to current file
map("n", "<leader>T", function()
  local bufname = vim.fn.expand("%:t")
  local output = vim.fn.system({ "pike", "--scope", bufname })
  if vim.v.shell_error == 0 and output ~= "" then
    local lines = vim.split(output, "\n", { trimempty = true })
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
  end
end, { desc = "Insert pike output" })

-- Helix: space+o — ensure note (create from template if missing)
local note_types = {
  p = "person",
  j = "project",
  a = "adr",
  c = "company",
  d = "decision",
  i = "incident",
}
for key, ntype in pairs(note_types) do
  map("n", "<leader>o" .. key, function()
    local word = vim.fn.expand("<cWORD>")
    -- Strip [[ ]] if present
    local name = word:match("%[%[(.-)%]%]") or word
    if name == "" then return end
    vim.fn.system({ "fish", "-lc", "_hx_ensure_note " .. ntype .. " <<< " .. vim.fn.shellescape(name) })
    -- Read the path written by _hx_ensure_note
    local f = io.open("/tmp/hx_note_path", "r")
    if f then
      local path = f:read("*a")
      f:close()
      if path and path ~= "" then
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      end
    end
  end, { desc = "Ensure " .. ntype .. " note" })
end
