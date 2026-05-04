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

    plugins.mini = {
      enable = true;
      modules = {
        surround = {};
        pairs = {};
        icons = {};
        statusline = {
          use_icons = true;
        };
      };
    };

    plugins.snacks = {
      enable = true;
      settings = {
        picker = { enabled = true; };
        notifier = { enabled = true; };
        lazygit = { enabled = true; };
      };
    };

    plugins.flash = {
      enable = true;
      settings = {};
    };

    extraPlugins = with pkgs.vimPlugins; [
      yazi-nvim
    ];

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

      # Snacks: file picker
      { mode = "n"; key = "<leader>ff"; action.__raw = ''function() Snacks.picker.files() end''; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>fr"; action.__raw = ''function() Snacks.picker.recent() end''; options.desc = "Recent files"; }
      { mode = "n"; key = "<leader>fg"; action.__raw = ''function() Snacks.picker.grep() end''; options.desc = "Find in project"; }

      # Snacks: buffer picker
      { mode = "n"; key = "<leader>bb"; action.__raw = ''function() Snacks.picker.buffers() end''; options.desc = "Buffer list"; }
      { mode = "n"; key = "<leader>bd"; action.__raw = ''function() Snacks.bufdelete() end''; options.desc = "Delete buffer"; }

      # Snacks: global search
      { mode = "n"; key = "<leader>/g"; action.__raw = ''function() Snacks.picker.grep() end''; options.desc = "Live grep"; }
      { mode = "n"; key = "<leader>/w"; action.__raw = ''function() Snacks.picker.grep_word() end''; options.desc = "Grep word under cursor"; }

      # Snacks: symbol picker
      { mode = "n"; key = "<leader>sd"; action.__raw = ''function() Snacks.picker.lsp_symbols() end''; options.desc = "Document symbols"; }
      { mode = "n"; key = "<leader>sw"; action.__raw = ''function() Snacks.picker.lsp_workspace_symbols() end''; options.desc = "Workspace symbols"; }

      # Snacks: diagnostics
      { mode = "n"; key = "<leader>df"; action.__raw = ''function() vim.diagnostic.open_float() end''; options.desc = "Open float"; }
      { mode = "n"; key = "<leader>dn"; action.__raw = ''function() vim.diagnostic.goto_next() end''; options.desc = "Next diagnostic"; }
      { mode = "n"; key = "<leader>dp"; action.__raw = ''function() vim.diagnostic.goto_prev() end''; options.desc = "Prev diagnostic"; }
      { mode = "n"; key = "<leader>dl"; action.__raw = ''function() Snacks.picker.diagnostics() end''; options.desc = "List all"; }

      # Snacks: git
      { mode = "n"; key = "<leader>gg"; action.__raw = ''function() Snacks.lazygit() end''; options.desc = "Lazygit"; }

      # Flash
      { mode = "n"; key = "<CR>"; action.__raw = ''function() require("flash").jump() end''; options.desc = "Flash jump"; }
      { mode = ["n" "x" "o"]; key = "S"; action.__raw = ''function() require("flash").treesitter() end''; options.desc = "Flash treesitter"; }
    ];

    extraConfigLua = ''
      -- Mini.clue setup (needs Lua function refs that can't be expressed in Nix)
      local miniclue = require("mini.clue")
      miniclue.setup({
        triggers = {
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },
          { mode = "n", keys = "<C-w>" },
        },
        clues = {
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
          { mode = "n", keys = "<Leader>f", desc = "+Files" },
          { mode = "n", keys = "<Leader>b", desc = "+Buffers" },
          { mode = "n", keys = "<Leader>/", desc = "+Search" },
          { mode = "n", keys = "<Leader>s", desc = "+Symbols" },
          { mode = "n", keys = "<Leader>d", desc = "+Diagnostics" },
          { mode = "n", keys = "<Leader>g", desc = "+Git" },
          { mode = "n", keys = "<Leader>c", desc = "+Code" },
          { mode = "n", keys = "<Leader>o", desc = "+Notes" },
        },
        window = {
          delay = 300,
          config = { width = "auto" },
        },
      })

      -- Yazi file picker
      require("yazi").setup({
        open_for_directories = false,
      })
      vim.keymap.set("n", "<C-y>", "<cmd>Yazi<CR>", { desc = "Open yazi" })

      -- Toggle task syntax: "- " → "- [ ] " → "- "
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
      vim.keymap.set({ "n", "v" }, "<leader>t", toggle_task_syntax, { desc = "Toggle task syntax" })

      -- Toggle task check with @completed date
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
      vim.keymap.set({ "n", "v" }, "<leader>x", toggle_task_check, { desc = "Toggle task check" })

      -- Pike integration: insert pike output scoped to current file
      vim.keymap.set("n", "<leader>T", function()
        local bufname = vim.fn.expand("%:t")
        local output = vim.fn.system({ "pike", "--scope", bufname })
        if vim.v.shell_error == 0 and output ~= "" then
          local lines = vim.split(output, "\n", { trimempty = true })
          local row = vim.api.nvim_win_get_cursor(0)[1]
          vim.api.nvim_buf_set_lines(0, row, row, false, lines)
        end
      end, { desc = "Insert pike output" })

      -- Note creation keymaps
      local note_types = {
        p = "person",
        j = "project",
        a = "adr",
        c = "company",
        d = "decision",
        i = "incident",
      }
      for key, ntype in pairs(note_types) do
        vim.keymap.set("n", "<leader>o" .. key, function()
          local word = vim.fn.expand("<cWORD>")
          local name = word:match("%[%[(.-)%]%]") or word
          if name == "" then return end
          vim.fn.system({ "fish", "-lc", "_hx_ensure_note " .. ntype .. " <<< " .. vim.fn.shellescape(name) })
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
    '';
  };
}
