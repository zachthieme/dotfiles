# NixVim Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the lazy.nvim-based neovim config with a fully Nix-managed NixVim Home Manager module — no runtime downloads, all plugins/LSPs/grammars from Nix.

**Architecture:** Add NixVim as a flake input, thread its HM module through both builders (darwin + linux), create `home-manager/programs/neovim.nix` with all config declared in Nix, then remove the old `config/nvim/` directory and package references.

**Tech Stack:** Nix, NixVim, Home Manager, neovim

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `flake.nix` | Add nixvim input, pass to builders |
| Modify | `modules/darwin/mk-config.nix` | Accept and import nixvim HM module |
| Modify | `modules/home-manager/mk-config.nix` | Accept and import nixvim HM module |
| Create | `home-manager/programs/neovim.nix` | Complete NixVim configuration |
| Modify | `home-manager/base.nix` | Import neovim.nix, remove nvim symlink |
| Modify | `packages/common.nix` | Remove `neovim` from corePackages |
| Delete | `config/nvim/` | Entire directory (replaced by NixVim) |

---

### Task 1: Add NixVim flake input

**Files:**
- Modify: `flake.nix`

- [ ] **Step 1: Add nixvim to flake inputs**

In `flake.nix`, add the nixvim input after the `catppuccin` input:

```nix
nixvim = {
  url = "github:nix-community/nixvim";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

- [ ] **Step 2: Add nixvim to the outputs function parameters**

Add `nixvim` to the destructured set in `outputs`:

```nix
outputs =
  {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    catppuccin,
    nixvim,
    claude-code,
    pike,
    tick,
    wen,
    grove,
    ...
  }:
```

- [ ] **Step 3: Pass nixvim to both builders**

Update `mkDarwinConfig`:
```nix
mkDarwinConfig = import ./modules/darwin/mk-config.nix {
  inherit nix-darwin home-manager catppuccin nixvim helpers customOverlays;
};
```

Update `mkHomeConfig`:
```nix
mkHomeConfig = import ./modules/home-manager/mk-config.nix {
  inherit home-manager nixpkgs catppuccin nixvim helpers customOverlays;
};
```

- [ ] **Step 4: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: No syntax errors. May show warnings about unused `nixvim` in builders (we'll fix that next).

- [ ] **Step 5: Commit**

```bash
jj commit -m "nvim: add nixvim flake input"
```

---

### Task 2: Thread NixVim HM module through builders

**Files:**
- Modify: `modules/darwin/mk-config.nix`
- Modify: `modules/home-manager/mk-config.nix`

- [ ] **Step 1: Update Darwin builder to accept and import nixvim**

In `modules/darwin/mk-config.nix`, add `nixvim` to the function parameters:

```nix
{ nix-darwin, home-manager, catppuccin, nixvim, helpers, customOverlays }:
```

Add `nixvim.homeManagerModules.nixvim` to the HM imports list (alongside `catppuccin.homeModules.catppuccin`):

```nix
home-manager.users.${user} = {
  imports = [
    catppuccin.homeModules.catppuccin
    nixvim.homeManagerModules.nixvim
    contextHomeModule
  ];
```

- [ ] **Step 2: Update Linux builder to accept and import nixvim**

In `modules/home-manager/mk-config.nix`, add `nixvim` to the function parameters:

```nix
{ home-manager, nixpkgs, catppuccin, nixvim, helpers, customOverlays }:
```

Add `nixvim.homeManagerModules.nixvim` to the modules list:

```nix
modules = [
  catppuccin.homeModules.catppuccin
  nixvim.homeManagerModules.nixvim
  contextModule
  {
```

- [ ] **Step 3: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation (nixvim module imported but not yet configured).

- [ ] **Step 4: Commit**

```bash
jj commit -m "nvim: thread nixvim HM module through builders"
```

---

### Task 3: Create neovim.nix with options and globals

**Files:**
- Create: `home-manager/programs/neovim.nix`
- Modify: `home-manager/base.nix`

- [ ] **Step 1: Create the neovim.nix module skeleton**

Create `home-manager/programs/neovim.nix`:

```nix
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
  };
}
```

- [ ] **Step 2: Import neovim.nix in base.nix**

Add `./programs/neovim.nix` to the imports list in `home-manager/base.nix`:

```nix
imports = [
  ./programs/bat.nix
  ./programs/btop.nix
  ./programs/fish
  ./programs/ghostty.nix
  ./programs/git.nix
  ./programs/helix.nix
  ./programs/jujutsu.nix
  ./programs/lazygit.nix
  ./programs/neovim.nix
  ./programs/pike.nix
  ./programs/ssh.nix
  ./programs/tmux.nix
  ./programs/wen.nix
  ./programs/zellij.nix
];
```

- [ ] **Step 3: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation. NixVim enabled with basic options.

- [ ] **Step 4: Commit**

```bash
jj commit -m "nvim: add neovim.nix with options and globals"
```

---

### Task 4: Add colorscheme

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add catppuccin colorscheme configuration**

Add inside `programs.nixvim`:

```nix
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
```

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation.

- [ ] **Step 3: Commit**

```bash
jj commit -m "nvim: add catppuccin colorscheme"
```

---

### Task 5: Add treesitter

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add treesitter configuration**

Add inside `programs.nixvim`:

```nix
plugins.treesitter = {
  enable = true;
  nixGrammars = true;
  settings = {
    highlight.enable = true;
    indent.enable = true;
  };
};
```

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation.

- [ ] **Step 3: Commit**

```bash
jj commit -m "nvim: add treesitter with nix grammars"
```

---

### Task 6: Add LSP configuration

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add LSP servers**

Add inside `programs.nixvim`:

```nix
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
```

Note: `installCargo = false` and `installRustc = false` for rust_analyzer because rustup manages the toolchain separately.

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation.

- [ ] **Step 3: Commit**

```bash
jj commit -m "nvim: add LSP servers and keymaps"
```

---

### Task 7: Add completion (blink-cmp)

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add blink-cmp configuration**

Add inside `programs.nixvim`:

```nix
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
```

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation.

- [ ] **Step 3: Commit**

```bash
jj commit -m "nvim: add blink-cmp completion"
```

---

### Task 8: Add standard keymaps

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add keymaps list**

Add inside `programs.nixvim`:

```nix
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
```

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation.

- [ ] **Step 3: Commit**

```bash
jj commit -m "nvim: add standard keymaps"
```

---

### Task 9: Add mini.nvim plugins

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add mini plugin configuration**

Add inside `programs.nixvim`:

```nix
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
```

- [ ] **Step 2: Add mini.clue setup via extraConfigLua**

Mini.clue requires Lua function references (`gen_clues.*`) that cannot be expressed as pure Nix attrsets. Add to `programs.nixvim.extraConfigLua`:

```nix
extraConfigLua = ''
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
'';
```

- [ ] **Step 3: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation.

- [ ] **Step 4: Commit**

```bash
jj commit -m "nvim: add mini.nvim plugins with clue setup"
```

---

### Task 10: Add snacks.nvim

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add snacks plugin configuration**

Add inside `programs.nixvim`. First try the native module:

```nix
plugins.snacks = {
  enable = true;
  settings = {
    picker = { enabled = true; };
    notifier = { enabled = true; };
    lazygit = { enabled = true; };
  };
};
```

If `plugins.snacks` doesn't exist in the NixVim version, fall back to `extraPlugins`:

```nix
extraPlugins = with pkgs.vimPlugins; [
  snacks-nvim
];
```

And configure via `extraConfigLua`.

- [ ] **Step 2: Add snacks keymaps**

Add to the `keymaps` list:

```nix
# File picker
{ mode = "n"; key = "<leader>ff"; action.__raw = ''function() Snacks.picker.files() end''; options.desc = "Find files"; }
{ mode = "n"; key = "<leader>fr"; action.__raw = ''function() Snacks.picker.recent() end''; options.desc = "Recent files"; }
{ mode = "n"; key = "<leader>fg"; action.__raw = ''function() Snacks.picker.grep() end''; options.desc = "Find in project"; }

# Buffer picker
{ mode = "n"; key = "<leader>bb"; action.__raw = ''function() Snacks.picker.buffers() end''; options.desc = "Buffer list"; }
{ mode = "n"; key = "<leader>bd"; action.__raw = ''function() Snacks.bufdelete() end''; options.desc = "Delete buffer"; }

# Global search
{ mode = "n"; key = "<leader>/g"; action.__raw = ''function() Snacks.picker.grep() end''; options.desc = "Live grep"; }
{ mode = "n"; key = "<leader>/w"; action.__raw = ''function() Snacks.picker.grep_word() end''; options.desc = "Grep word under cursor"; }

# Symbol picker
{ mode = "n"; key = "<leader>sd"; action.__raw = ''function() Snacks.picker.lsp_symbols() end''; options.desc = "Document symbols"; }
{ mode = "n"; key = "<leader>sw"; action.__raw = ''function() Snacks.picker.lsp_workspace_symbols() end''; options.desc = "Workspace symbols"; }

# Diagnostics
{ mode = "n"; key = "<leader>df"; action.__raw = ''function() vim.diagnostic.open_float() end''; options.desc = "Open float"; }
{ mode = "n"; key = "<leader>dn"; action.__raw = ''function() vim.diagnostic.goto_next() end''; options.desc = "Next diagnostic"; }
{ mode = "n"; key = "<leader>dp"; action.__raw = ''function() vim.diagnostic.goto_prev() end''; options.desc = "Prev diagnostic"; }
{ mode = "n"; key = "<leader>dl"; action.__raw = ''function() Snacks.picker.diagnostics() end''; options.desc = "List all"; }

# Git
{ mode = "n"; key = "<leader>gg"; action.__raw = ''function() Snacks.lazygit() end''; options.desc = "Lazygit"; }
```

- [ ] **Step 3: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation.

- [ ] **Step 4: Commit**

```bash
jj commit -m "nvim: add snacks.nvim with picker and lazygit"
```

---

### Task 11: Add flash.nvim

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add flash plugin and keymaps**

Add inside `programs.nixvim`:

```nix
plugins.flash = {
  enable = true;
  settings = {};
};
```

Add to the `keymaps` list:

```nix
# Flash jump
{ mode = "n"; key = "<CR>"; action.__raw = ''function() require("flash").jump() end''; options.desc = "Flash jump"; }
{ mode = ["n" "x" "o"]; key = "S"; action.__raw = ''function() require("flash").treesitter() end''; options.desc = "Flash treesitter"; }
```

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation.

- [ ] **Step 3: Commit**

```bash
jj commit -m "nvim: add flash.nvim"
```

---

### Task 12: Add extra plugins (yazi, vimdeck)

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add yazi.nvim and vimdeck.nvim**

Add/extend `extraPlugins` inside `programs.nixvim`:

```nix
extraPlugins = with pkgs.vimPlugins; [
  yazi-nvim
  (pkgs.vimUtils.buildVimPlugin {
    pname = "vimdeck-nvim";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "ducks";
      repo = "vimdeck.nvim";
      rev = "main";
      hash = "";  # Will fail first build — use the correct hash from error output
    };
  })
];
```

Note: The `hash` will need to be filled in. Run the build, get the expected hash from the error message, and fill it in.

- [ ] **Step 2: Add yazi keymap and config to extraConfigLua**

Append to `extraConfigLua`:

```lua
-- Yazi file picker
require("yazi").setup({
  open_for_directories = false,
})
vim.keymap.set("n", "<C-y>", "<cmd>Yazi<CR>", { desc = "Open yazi" })
```

- [ ] **Step 3: Add vimdeck config to extraConfigLua**

Append to `extraConfigLua`:

```lua
-- Vimdeck presentations
require("vimdeck").setup({
  use_figlet = true,
  center_vertical = true,
  center_horizontal = true,
})
```

- [ ] **Step 4: Verify flake evaluates (fix vimdeck hash)**

Run: `nix build .#homeConfigurations.srv722852.activationPackage 2>&1 | grep "got:"`

Take the hash from the error and replace the empty string in the `hash` field.

- [ ] **Step 5: Commit**

```bash
jj commit -m "nvim: add yazi and vimdeck extra plugins"
```

---

### Task 13: Add custom Lua functions

**Files:**
- Modify: `home-manager/programs/neovim.nix`

- [ ] **Step 1: Add task toggle and pike/notes functions to extraConfigLua**

Append to `extraConfigLua`:

```lua
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
```

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation.

- [ ] **Step 3: Commit**

```bash
jj commit -m "nvim: add custom lua functions (tasks, pike, notes)"
```

---

### Task 14: Remove old neovim config and package

**Files:**
- Modify: `home-manager/base.nix`
- Modify: `packages/common.nix`
- Delete: `config/nvim/`

- [ ] **Step 1: Remove nvim symlink from base.nix**

In `home-manager/base.nix`, remove this line from `home.file`:

```nix
".config/nvim".source = ../config/nvim;
```

- [ ] **Step 2: Remove neovim from corePackages**

In `packages/common.nix`, remove `neovim` from the `corePackages` list.

- [ ] **Step 3: Remove markdown-oxide from corePackages**

In `packages/common.nix`, remove `markdown-oxide` from `corePackages` — NixVim's LSP config now provides it.

- [ ] **Step 4: Delete config/nvim/ directory**

```bash
rm -rf config/nvim/
```

- [ ] **Step 5: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`

Expected: Clean evaluation, no references to deleted files.

- [ ] **Step 6: Commit**

```bash
jj commit -m "nvim: remove old config/nvim and neovim package"
```

---

### Task 15: Full build verification

**Files:** None (verification only)

- [ ] **Step 1: Build the full configuration**

For the current host (Linux):

```bash
home-manager switch --dry-run --flake .#srv722852
```

Expected: Successful dry-run with no errors.

- [ ] **Step 2: Apply the configuration**

```bash
home-manager switch --flake .#srv722852
```

Expected: Activation succeeds.

- [ ] **Step 3: Verify neovim launches with correct config**

```bash
nvim --headless -c "echo v:true" -c "qa" 2>&1
```

Open nvim and verify:
- Catppuccin theme loads
- `:checkhealth` shows LSP servers available
- Treesitter highlighting works on a Lua file
- `<leader>` triggers mini.clue popup after 300ms
- `<leader>ff` opens file picker
- Completion triggers in insert mode

- [ ] **Step 4: Commit any fixes**

If any adjustments were needed during verification, commit them:

```bash
jj commit -m "nvim: fix issues found during verification"
```
