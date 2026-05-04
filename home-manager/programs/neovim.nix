{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Indentation
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      smartindent = true;

      # System clipboard
      clipboard = "unnamedplus";

      # Search
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;

      # UI
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      sidescrolloff = 8;
      splitbelow = true;
      splitright = true;

      # Misc
      undofile = true;
      updatetime = 250;
      timeoutlen = 400;
      completeopt = "menu,menuone,noselect";
      showmode = false;
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        no_italic = true;
        integrations = {
          blink_cmp = true;
          mini = { enabled = true; };
          snacks = true;
          treesitter = true;
        };
      };
    };

    plugins.treesitter = {
      enable = true;
      nixGrammars = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    plugins.lsp = {
      enable = true;
      servers = {
        lua_ls.enable = true;
        gopls.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        ts_ls.enable = true;
        bashls.enable = true;
        markdown_oxide.enable = true;
      };
      keymaps = {
        lspBuf = {
          gd = "definition";
          gr = "references";
          gy = "type_definition";
          gD = "declaration";
          K = "hover";
          "<leader>ca" = "code_action";
          "<leader>cr" = "rename";
        };
        extra = [
          {
            mode = "n";
            key = "<leader>cf";
            action.__raw = ''function() vim.lsp.buf.format({ async = true }) end'';
            options.desc = "Format buffer";
          }
        ];
      };
    };

    plugins.blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "default";
        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "mono";
        };
        sources.default = [ "lsp" "path" "snippets" "buffer" ];
      };
    };

    keymaps = [
      # Clear search highlight
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }

      # Window navigation
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move to left window"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move to lower window"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move to upper window"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move to right window"; }

      # Buffer navigation
      { mode = "n"; key = "<S-h>"; action = "<cmd>bprevious<CR>"; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<S-l>"; action = "<cmd>bnext<CR>"; options.desc = "Next buffer"; }

      # Better indenting (stay in visual mode)
      { mode = "v"; key = "<"; action = "<gv"; }
      { mode = "v"; key = ">"; action = ">gv"; }

      # Move lines
      { mode = "n"; key = "<A-j>"; action = "<cmd>m .+1<CR>=="; options.desc = "Move line down"; }
      { mode = "n"; key = "<A-k>"; action = "<cmd>m .-2<CR>=="; options.desc = "Move line up"; }
      { mode = "v"; key = "<A-j>"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move selection down"; }
      { mode = "v"; key = "<A-k>"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move selection up"; }
    ];
  };
}
