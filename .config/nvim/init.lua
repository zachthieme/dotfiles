-- set leader key to space
vim.g.mapleader = ' '

local set = vim.opt
local var = vim.api.nvim_set_var

-- set relative / regular number
set.relativenumber = true
set.number = true

-- Set the behavior of tab
set.tabstop = 2
set.shiftwidth = 2
set.softtabstop = 2
set.expandtab = true
set.smarttab = true
set.autoindent = true

-- set jursor line
-- set.cursorline = true

-- NERDTree Settings
var('NERDTreeShowHidden', 1)

-- set key bindings
function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end


------------------------------------------
--            editor  config            --
------------------------------------------
-- show cursor line only in active window
-- TODO: figure out how to make it highlight the line
local cursorGrp = vim.api.nvim_create_augroup("CursorLine", { clear = true })

vim.api.nvim_create_autocmd(
  { "InsertLeave", "WinEnter" },
  { pattern = "*", command = "set nocursorline", group = cursorGrp }
)

vim.api.nvim_create_autocmd(
  { "InsertEnter", "WinLeave" },
  { pattern = "*", command = "set cursorline", group = cursorGrp }
)

-- need to figure out how to make it work
-- vim.api.nvim_create_autocmd(
--  [[ autocmd BufEnter * lcd %:p:h ]]
-- )
------------------------------------------
--           Set key bindings           --
------------------------------------------

-- select all  
map('n','<Leader>a', 'ggVG')

-- flatten newline list into comma seperated
map('n', '<leader>l',[[ :%s/\n/,/g<CR> ]])

-- move to split with arrow keys
map('n','<Right>','<C-w>l')
map('n','<Left>','<C-w>h')
map('n','<Up>','<C-w>j')
map('n','<Down>','<C-w>k')

-- paste the last thing yanked not deleted
map('n', ',p', '"0p')

-- remap jj to esc  
map('i','jj','<Esc>')

-- write only if something has changed
--
map('n', '<Leader>w', ':up<cr>')

-- NerdTree Bindings
map('n','<Leader>n',':NERDTreeToggle<CR>')

-- telescope bindings 
map('n', '<Leader>o','<cmd>Telescope find_files<cr>')
map('n', '<leader>f','<cmd>Telescope live_grep<cr>')
map('n', '<leader>b','<cmd>Telescope buffers<cr>')
map('n', '<leader>h','<cmd>Telescope help_tags<cr>')

-- set semicolon to enter commands 
map('n', ';', ':')

-- set colon to advance to next item in f/t
map('n', ':', ';')

-- configure plugins
return require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'vim-airline/vim-airline'
  use 'tpope/vim-surround'
  use 'jiangmiao/auto-pairs'
  use 'jeffkreeftmeijer/vim-numbertoggle'
  use 'liuchengxu/vim-which-key'
  use 'psliwka/vim-smoothie'
  use 'preservim/nerdtree'
  use 'easymotion/vim-easymotion'
  use 'prabirshrestha/vim-lsp'
  use 'neovim/nvim-lspconfig'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'rakr/vim-one' 
  use 'preservim/nerdcommenter'
  use 'vimwiki/vimwiki'
  use 'justinmk/vim-sneak'
  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup(
    {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    })
    end}
  --use('nvim-treesitter/nvim-treesitter', {'do' = ':TSUpdate'})
  end)

local Terminal = require("toggleterm.terminal").Terminal
local gitui = Terminal:new({ cmd = "gitui", hidden = true })

function _GITUI_TOGGLE()
	gitui:toggle()
end
