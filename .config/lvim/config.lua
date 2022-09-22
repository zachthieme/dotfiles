--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
vim.opt.relativenumber = true

-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "onedarker"
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping

-- Move between splits with arrows
lvim.keys.normal_mode['<Right>'] = '<C-w>l'
lvim.keys.normal_mode['<Left>'] = '<C-w>h'
lvim.keys.normal_mode['<Up>'] = '<C-w>j'
lvim.keys.normal_mode['<Down>'] = '<C-w>k'

-- select all
lvim.keys.normal_mode['<Leader>a'] = 'ggVG'

-- flatten newline list into comma seperated
lvim.keys.normal_mode['<leader>l'] = [[ :%s/\n/,/g<CR> ]]

-- Save if changed
lvim.keys.normal_mode['<C-w>'] = ':up<CR>'

-- save and quit
lvim.keys.normal_mode["<C-q>"] = ":x<CR>"

-- quit without saving
lvim.keys.normal_mode["<C-e>"] = ":q!<CR>"

-- telescope bindings
lvim.keys.normal_mode['<Leader>o'] = '<cmd>Telescope find_files<cr>'
lvim.keys.normal_mode['<leader>f'] = '<cmd>Telescope live_grep<cr>'
lvim.keys.normal_mode['<leader>b'] = '<cmd>Telescope buffers<cr>'
lvim.keys.normal_mode['<leader>h'] = '<cmd>Telescope help_tags<cr>'

-- paste the last thing yanked not deleted
lvim.keys.normal_mode[',p'] = '"0p'

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- Set the default bindings for toggle term
lvim.builtin.terminal.open_mapping = [[<C-\>]]
lvim.builtin.terminal.terminal_mappings = true

lvim.builtin.cmp.sources = {
  { name = "nvim_lsp" },
  { name = "nvim_lua" },
  { name = "buffer", keyword_length = 5 },
  { name = "path", max_item_count = 5 }
}

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- Additional Plugins
lvim.plugins = {
  { 'tpope/vim-surround' },
  { 'vimwiki/vimwiki' },
  --     {"folke/tokyonight.nvim"},
  --     {
  --       "folke/trouble.nvim",
  --       cmd = "TroubleToggle",
  --     },
}
