# NixVim Migration Design

Migrate neovim configuration from lazy.nvim + symlinked Lua files to a fully Nix-managed NixVim Home Manager module.

## Goal

Fully reproducible neovim setup with no runtime downloads — all plugins, LSP servers, and treesitter grammars provided by Nix. 1:1 feature parity with the existing config.

## Architecture

### Flake Integration

Add `nixvim` flake input:
```nix
inputs.nixvim = {
  url = "github:nix-community/nixvim";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Pass `nixvim` to both `mkDarwinConfig` and `mkHomeConfig`. Each builder imports `nixvim.homeManagerModules.nixvim` into the HM modules list (same pattern as `catppuccin.homeModules.catppuccin`).

### File Changes

| Action | File | Detail |
|--------|------|--------|
| Create | `home-manager/programs/neovim.nix` | All NixVim configuration |
| Modify | `flake.nix` | Add nixvim input, pass HM module to builders |
| Modify | `home-manager/base.nix` | Add neovim.nix import, remove nvim symlink |
| Modify | `packages/common.nix` | Remove `neovim` from corePackages |
| Modify | `modules/darwin/mk-config.nix` | Pass nixvim HM module |
| Modify | `modules/home-manager/mk-config.nix` | Pass nixvim HM module |
| Delete | `config/nvim/` | Entire directory (replaced by NixVim) |

## Plugin Mapping

| Current (lazy.nvim) | NixVim | Notes |
|---|---|---|
| `catppuccin/nvim` | `colorschemes.catppuccin` | Declarative flavour + integrations |
| `echasnovski/mini.nvim` | `plugins.mini` | Sub-modules: surround, pairs, icons, statusline, clue |
| `folke/snacks.nvim` | `plugins.snacks` | Fallback: `extraPlugins` if no native module |
| `saghen/blink.cmp` | `plugins.blink-cmp` | Native support |
| `folke/flash.nvim` | `plugins.flash` | Native support |
| `nvim-treesitter` | `plugins.treesitter` | `nixGrammars = true`, no `:TSUpdate` |
| `mason + lspconfig` | `plugins.lsp` | Mason eliminated entirely |
| `mikavilpas/yazi.nvim` | `extraPlugins` | Configure via extraConfigLua |
| `ducks/vimdeck.nvim` | `extraPlugins` | Configure via extraConfigLua |

## LSP Servers

All via `plugins.lsp.servers`:
- `lua_ls.enable = true`
- `gopls.enable = true`
- `rust_analyzer.enable = true`
- `ts_ls.enable = true`
- `bashls.enable = true`
- `markdown_oxide.enable = true`

No Mason, no runtime installs. Nix provides all server binaries.

## Treesitter

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

All grammars pre-compiled from nixpkgs. No network access needed at runtime.

## Options & Globals

```nix
globals = {
  mapleader = " ";
  maplocalleader = " ";
};

opts = {
  number = true;
  relativenumber = true;
  tabstop = 2;
  shiftwidth = 2;
  softtabstop = 2;
  expandtab = true;
  smartindent = true;
  clipboard = "unnamedplus";
  ignorecase = true;
  smartcase = true;
  hlsearch = true;
  incsearch = true;
  termguicolors = true;
  signcolumn = "yes";
  cursorline = true;
  scrolloff = 8;
  sidescrolloff = 8;
  splitbelow = true;
  splitright = true;
  undofile = true;
  updatetime = 250;
  timeoutlen = 400;
  completeopt = "menu,menuone,noselect";
  showmode = false;
};
```

## Keymaps

### Standard keymaps (via `keymaps` list)

```nix
keymaps = [
  # Clear search
  { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }

  # Window navigation
  { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move to left window"; }
  { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move to lower window"; }
  { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move to upper window"; }
  { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move to right window"; }

  # Buffer navigation
  { mode = "n"; key = "<S-h>"; action = "<cmd>bprevious<CR>"; options.desc = "Previous buffer"; }
  { mode = "n"; key = "<S-l>"; action = "<cmd>bnext<CR>"; options.desc = "Next buffer"; }

  # Better indenting
  { mode = "v"; key = "<"; action = "<gv"; }
  { mode = "v"; key = ">"; action = ">gv"; }

  # Move lines
  { mode = "n"; key = "<A-j>"; action = "<cmd>m .+1<CR>=="; options.desc = "Move line down"; }
  { mode = "n"; key = "<A-k>"; action = "<cmd>m .-2<CR>=="; options.desc = "Move line up"; }
  { mode = "v"; key = "<A-j>"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move selection down"; }
  { mode = "v"; key = "<A-k>"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move selection up"; }
];
```

### LSP keymaps (via `plugins.lsp.keymaps`)

```nix
plugins.lsp.keymaps.lspBuf = {
  gd = "definition";
  gr = "references";
  gy = "type_definition";
  gD = "declaration";
  K = "hover";
  "<leader>ca" = "code_action";
  "<leader>cr" = "rename";
};
```

Format keymap via `extraConfigLua` or `plugins.lsp.keymaps.extra`.

### Snacks picker keymaps

Configured via `plugins.snacks` key mappings or `extraConfigLua` depending on NixVim module support.

### Flash keymaps

```nix
plugins.flash = {
  enable = true;
  settings = {};
};
# Plus keymaps in the top-level keymaps list
```

## Custom Lua (extraConfigLua)

These functions have no NixVim declarative equivalent and remain as raw Lua:

1. **toggle_task_syntax** (`<leader>t`) — Cycles `- ` / `- [ ] ` prefix
2. **toggle_task_check** (`<leader>x`) — Toggles `[ ]` / `[x]` with `@completed(date)`
3. **Pike integration** (`<leader>T`) — Inserts pike output scoped to current file
4. **Note creation** (`<leader>o{p,j,a,c,d,i}`) — Creates notes from templates via fish function

## Mini.clue Configuration

The clue triggers and group descriptions go in `plugins.mini.modules.clue`. The `gen_clues.*` helpers require Lua function references, so we'll use a `__raw` escape or `extraConfigLua` to call:
- `miniclue.gen_clues.builtin_completion()`
- `miniclue.gen_clues.g()`
- `miniclue.gen_clues.marks()`
- `miniclue.gen_clues.registers()`
- `miniclue.gen_clues.windows()`
- `miniclue.gen_clues.z()`

## Colorscheme

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

Note: The existing global `catppuccin` HM module (`catppuccin.enable = true`) handles theming for other tools (bat, fish, etc.). The NixVim colorscheme config is separate and specific to neovim.

## Completion (blink.cmp)

```nix
plugins.blink-cmp = {
  enable = true;
  settings = {
    keymap.preset = "default";
    appearance = {
      use_nvim_cmp_as_default = true;
      nerd_font_variant = "mono";
    };
    sources.default = ["lsp" "path" "snippets" "buffer"];
  };
};
```

## Extra Plugins (no native NixVim module)

```nix
extraPlugins = with pkgs.vimPlugins; [
  yazi-nvim
  # vimdeck.nvim — may need to fetch from GitHub if not in nixpkgs
];
```

For vimdeck.nvim (not in nixpkgs), use `pkgs.vimUtils.buildVimPlugin`:
```nix
(pkgs.vimUtils.buildVimPlugin {
  pname = "vimdeck-nvim";
  version = "latest";
  src = pkgs.fetchFromGitHub {
    owner = "ducks";
    repo = "vimdeck.nvim";
    rev = "...";
    hash = "...";
  };
})
```

## What Gets Eliminated

- `lazy.nvim` — no plugin manager needed
- `mason.nvim` / `mason-lspconfig.nvim` — Nix provides LSP binaries
- `:TSUpdate` — grammars pre-compiled
- Runtime git clones — everything in the Nix store
- `config/nvim/` directory — replaced entirely by `neovim.nix`

## Verification

After migration:
1. `home-manager switch --flake .#<host>` succeeds
2. `nvim` opens with catppuccin theme
3. LSP attaches (test with a `.lua`, `.go`, `.rs` file)
4. Treesitter highlighting works
5. All keymaps functional (picker, flash, task toggles)
6. `<leader>` shows clue popup after 300ms
7. Completion works in insert mode
