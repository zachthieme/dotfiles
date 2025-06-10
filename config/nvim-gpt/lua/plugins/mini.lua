return {
  -- Mini.nvim - A collection of minimal, independent, and fast Lua modules
  {
    "echasnovski/mini.nvim",
    version = false, -- Use main branch for latest features
    event = "VeryLazy",
    config = function()
      -- Mini.ai - Extend and create `i` and `a` textobjects
      require("mini.ai").setup({
        n_lines = 500,
        custom_textobjects = {
          o = require("mini.ai").gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          i = require("mini.ai").gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }, {}),
          l = require("mini.ai").gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }, {}),
          u = require("mini.ai").gen_spec.function_call(), -- u for "Usage"
          U = require("mini.ai").gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      })

      -- Mini.align - Align text interactively
      require("mini.align").setup()

      -- Mini.animate - Animate common Neovim actions
      require("mini.animate").setup({
        cursor = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 100, unit = "total" }),
        },
        scroll = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 150, unit = "total" }),
        },
        resize = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 100, unit = "total" }),
        },
        open = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 150, unit = "total" }),
        },
        close = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 150, unit = "total" }),
        },
      })

      -- Mini.bracketed - Go forward/backward with square brackets
      require("mini.bracketed").setup({
        buffer = { suffix = "b", options = {} },
        comment = { suffix = "c", options = {} },
        conflict = { suffix = "x", options = {} },
        diagnostic = { suffix = "d", options = {} },
        file = { suffix = "f", options = {} },
        indent = { suffix = "i", options = {} },
        jump = { suffix = "j", options = {} },
        location = { suffix = "l", options = {} },
        oldfile = { suffix = "o", options = {} },
        quickfix = { suffix = "q", options = {} },
        reference = { suffix = "r", options = {} },
        spelling = { suffix = "s", options = {} },
        treesitter = { suffix = "t", options = {} },
        undo = { suffix = "u", options = {} },
        window = { suffix = "w", options = {} },
        yank = { suffix = "y", options = {} },
      })

      -- Mini.bufremove - Remove buffers
      require("mini.bufremove").setup()

      -- Mini.clue - Show next key clues
      local miniclue = require("mini.clue")
      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },

          -- Bracketed keys
          { mode = "n", keys = "[" },
          { mode = "n", keys = "]" },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
      })

      -- Mini.comment - Comment lines
      require("mini.comment").setup({
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
          end,
        },
      })

      -- Mini.cursorword - Highlight word under cursor
      require("mini.cursorword").setup()

      -- Mini.diff - Work with diff hunks
      require("mini.diff").setup({
        view = {
          style = "sign",
          signs = { add = "▎", change = "▎", delete = "▎" },
        },
      })

      -- Mini.extra - Extra functionality
      require("mini.extra").setup()

      -- Mini.files - File explorer
      require("mini.files").setup({
        content = {
          filter = nil,
          prefix = nil,
          sort = nil,
        },
        mappings = {
          close = "q",
          go_in = "l",
          go_in_plus = "L",
          go_out = "h",
          go_out_plus = "H",
          mark_goto = "'",
          mark_set = "m",
          reset = "<BS>",
          reveal_cwd = "@",
          show_help = "g?",
          synchronize = "=",
          trim_left = "<",
          trim_right = ">",
        },
        options = {
          permanent_delete = true,
          use_as_default_explorer = true,
        },
        windows = {
          max_number = math.huge,
          preview = false,
          width_focus = 25,
          width_nofocus = 15,
          width_preview = 25,
        },
      })

      -- Mini.fuzzy - Fuzzy matching
      require("mini.fuzzy").setup()

      -- Mini.hipatterns - Highlight patterns
      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
          todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
          note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })

      -- Mini.icons - Icon provider
      require("mini.icons").setup({
        file = {
          [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
          ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
        },
        filetype = {
          dotenv = { glyph = "", hl = "MiniIconsYellow" },
        },
      })

      -- Mini.indentscope - Visualize and work with indent scope
      require("mini.indentscope").setup({
        symbol = "│",
        options = { try_as_border = true },
      })

      -- Mini.jump - Jump to next/previous single character
      require("mini.jump").setup()

      -- Mini.jump2d - Jump within visible lines
      require("mini.jump2d").setup({
        spotter = require("mini.jump2d").gen_pattern_spotter("[^%s%p]+"),
        allowed_lines = {
          blank = true,
          cursor_before = true,
          cursor_at = true,
          cursor_after = true,
          fold = true,
        },
        allowed_windows = {
          current = true,
          not_current = false,
        },
        hooks = {
          before_start = nil,
          after_jump = nil,
        },
        mappings = {
          start_jumping = "<CR>",
        },
        silent = false,
      })

      -- Mini.move - Move any selection in any direction
      require("mini.move").setup({
        mappings = {
          left = "<M-h>",
          right = "<M-l>",
          down = "<M-j>",
          up = "<M-k>",
          line_left = "<M-h>",
          line_right = "<M-l>",
          line_down = "<M-j>",
          line_up = "<M-k>",
        },
        options = {
          reindent_linewise = true,
        },
      })

      -- Mini.pairs - Autopairs
      require("mini.pairs").setup({
        modes = { insert = true, command = false, terminal = false },
        skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        skip_ts = { "string" },
        skip_unbalanced = true,
        markdown = true,
      })

      -- Mini.pick - Pick anything
      require("mini.pick").setup({
        delay = {
          async = 10,
          busy = 50,
        },
        mappings = {
          caret_left = "<Left>",
          caret_right = "<Right>",
          choose = "<CR>",
          choose_in_split = "<C-s>",
          choose_in_tabpage = "<C-t>",
          choose_in_vsplit = "<C-v>",
          choose_marked = "<M-CR>",
          delete_char = "<BS>",
          delete_char_right = "<Del>",
          delete_left = "<C-u>",
          delete_word = "<C-w>",
          mark = "<C-x>",
          mark_all = "<C-a>",
          move_down = "<C-n>",
          move_start = "<C-g>",
          move_up = "<C-p>",
          paste = "<C-r>",
          refine = "<C-Space>",
          refine_marked = "<M-Space>",
          scroll_down = "<C-f>",
          scroll_left = "<C-h>",
          scroll_right = "<C-l>",
          scroll_up = "<C-b>",
          stop = "<Esc>",
          toggle_info = "<S-Tab>",
          toggle_preview = "<Tab>",
        },
        options = {
          content_from_bottom = false,
          use_cache = false,
        },
        source = {
          items = nil,
          name = nil,
          cwd = nil,
          match = nil,
          show = nil,
          preview = nil,
          choose = nil,
          choose_marked = nil,
        },
        window = {
          config = nil,
          prompt_cursor = "▏",
          prompt_prefix = "> ",
        },
      })

      -- Mini.splitjoin - Split and join arguments
      require("mini.splitjoin").setup({
        mappings = {
          toggle = "gS",
          split = "",
          join = "",
        },
        detect = {
          brackets = nil,
          separator = ",",
          exclude_regions = nil,
        },
        split = {
          hooks_pre = {},
          hooks_post = {},
        },
        join = {
          hooks_pre = {},
          hooks_post = {},
        },
      })

      -- Mini.starter - Start screen
      local starter = require("mini.starter")
      starter.setup({
        autoopen = true,
        evaluate_single = false,
        items = {
          starter.sections.builtin_actions(),
          starter.sections.recent_files(10, false),
          starter.sections.recent_files(10, true),
          {
            { action = "Lazy", name = "L: Lazy", section = "Lazy" },
            { action = "qall!", name = "Q: Quit", section = "Built-in actions" },
          },
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.indexing("all", { "Builtin actions" }),
          starter.gen_hook.padding(3, 2),
        },
        footer = "",
        header = table.concat({
          [[  ███╗   ██╗██╗   ██╗██╗███╗   ███╗]],
          [[  ████╗  ██║██║   ██║██║████╗ ████║]],
          [[  ██╔██╗ ██║██║   ██║██║██╔████╔██║]],
          [[  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
          [[  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║]],
          [[  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          [[                                   ]],
          [[           [ GPT Config ]          ]],
        }, "\n"),
        query_updaters = "abcdefghijklmnopqrstuvwxyz0123456789_-.",
      })

      -- Mini.statusline - Statusline
      require("mini.statusline").setup({
        content = {
          active = nil,
          inactive = nil,
        },
        use_icons = true,
        set_vim_settings = true,
      })

      -- Mini.surround - Surround actions
      require("mini.surround").setup({
        mappings = {
          add = "sa",
          delete = "sd",
          find = "sf",
          find_left = "sF",
          highlight = "sh",
          replace = "sr",
          update_n_lines = "sn",
          suffix_last = "l",
          suffix_next = "n",
        },
        custom_surroundings = nil,
        highlight_duration = 500,
        n_lines = 20,
        respect_selection_type = false,
        search_method = "cover",
        silent = false,
      })

      -- Mini.tabline - Tabline
      require("mini.tabline").setup({
        show_icons = true,
        set_vim_settings = true,
        tabpage_section = "left",
      })

      -- Mini.trailspace - Trailspace (highlight and remove)
      require("mini.trailspace").setup()

      -- Mini.visits - Track and reuse file system visits
      require("mini.visits").setup()
    end,
    keys = {
      -- Mini.files
      {
        "<leader>fm",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (directory of current file)",
      },
      {
        "<leader>fM",
        function()
          require("mini.files").open(vim.uv.cwd(), true)
        end,
        desc = "Open mini.files (cwd)",
      },
      -- Mini.pick
      { "<leader>ff", "<cmd>Pick files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Pick grep_live<cr>", desc = "Grep Live" },
      { "<leader>fb", "<cmd>Pick buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Pick help<cr>", desc = "Help" },
      { "<leader>fr", "<cmd>Pick oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fc", "<cmd>Pick commands<cr>", desc = "Commands" },
      { "<leader>fk", "<cmd>Pick keymaps<cr>", desc = "Keymaps" },
      { "<leader>fl", "<cmd>Pick buf_lines<cr>", desc = "Buffer Lines" },
      { "<leader>f:", "<cmd>Pick command_history<cr>", desc = "Command History" },
      { "<leader>f/", "<cmd>Pick search_history<cr>", desc = "Search History" },
      -- Mini.jump2d
      { "<leader>j", "<cmd>lua require('mini.jump2d').start()<cr>", desc = "Jump 2D" },
      -- Mini.bufremove
      { "<leader>bd", "<cmd>lua require('mini.bufremove').delete(0, false)<cr>", desc = "Delete Buffer" },
      { "<leader>bD", "<cmd>lua require('mini.bufremove').delete(0, true)<cr>", desc = "Delete Buffer (Force)" },
      -- Mini.visits
      { "<leader>fv", "<cmd>Pick visit_paths<cr>", desc = "Visit Paths" },
      -- Mini.extra
      { "<leader>fe", "<cmd>Pick diagnostic<cr>", desc = "Diagnostics" },
      { "<leader>ft", "<cmd>Pick treesitter<cr>", desc = "Treesitter" },
      { "<leader>fL", "<cmd>Pick lsp<cr>", desc = "LSP" },
    },
  },
}