# Neovim GPT Configuration

A comprehensive Neovim configuration built with Lazy package manager, featuring Snacks.nvim, Mini.nvim, and full LSP/DAP support for Go, Zig, C++, Lua, and Shell scripting.

## Features

### Core Plugins
- **Package Manager**: [Lazy.nvim](https://github.com/folke/lazy.nvim) for fast plugin management
- **UI Framework**: [Snacks.nvim](https://github.com/folke/snacks.nvim) for enhanced UI components
- **Mini Suite**: [Mini.nvim](https://github.com/echasnovski/mini.nvim) for lightweight, modular functionality

### Language Support
- **Go**: Full LSP with gopls, debugging with Delve, formatting with gofumpt/goimports
- **Zig**: LSP with ZLS, debugging with CodeLLDB
- **C/C++**: LSP with Clangd, debugging with CodeLLDB, formatting with clang-format
- **Lua**: LSP with lua-language-server, enhanced Neovim development with neodev
- **Shell**: LSP with bash-language-server, linting with shellcheck, formatting with shfmt

### Development Features
- **LSP**: Full Language Server Protocol support with auto-completion, diagnostics, and code actions
- **DAP**: Debug Adapter Protocol for debugging all supported languages
- **Completion**: nvim-cmp with LSP, snippet, buffer, and path sources
- **Syntax Highlighting**: Treesitter with comprehensive language support
- **Fuzzy Finding**: Telescope for files, buffers, grep, and more
- **Git Integration**: Gitsigns, LazyGit, git blame, conflict resolution
- **Formatting**: Conform.nvim with automatic format-on-save
- **Linting**: nvim-lint with language-specific linters

### UI Enhancements
- **Colorscheme**: TokyoNight (default), with Catppuccin and Gruvbox alternatives
- **File Explorer**: Mini.files for lightweight file management
- **Statusline**: Mini.statusline with icons and git integration
- **Which-key**: Key binding hints and documentation
- **Trouble**: Better diagnostics and quickfix lists
- **Flash**: Enhanced navigation and search

## Installation

### Prerequisites
Ensure you have the following installed:
- Neovim >= 0.9.0
- Git
- A C compiler (for treesitter)
- Node.js (for some LSP servers)
- Go (for Go development)
- Zig (for Zig development)
- Clang/GCC (for C/C++ development)

### Setup
1. **Backup existing config** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this configuration**:
   ```bash
   # If using this as a standalone config
   git clone <this-repo-url> ~/.config/nvim
   
   # Or if using from the dotfiles structure
   ln -s /path/to/dotfiles/config/nvim-gpt ~/.config/nvim
   ```

3. **Launch Neovim**:
   ```bash
   nvim
   ```

4. **Install dependencies**:
   The configuration will automatically:
   - Install Lazy.nvim
   - Download and install all plugins
   - Install Mason packages (LSP servers, formatters, linters)

## Key Bindings

### General
- `<Space>` - Leader key
- `<C-h/j/k/l>` - Navigate between windows
- `<S-h/l>` - Navigate between buffers
- `<A-j/k>` - Move lines up/down

### File Operations
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>fr` - Recent files
- `<leader>fm` - Open file manager (Mini.files)

### LSP
- `gd` - Go to definition
- `gr` - Go to references
- `gI` - Go to implementation
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>cr` - Rename symbol
- `<leader>cd` - Show diagnostics

### Debugging (DAP)
- `<leader>db` - Toggle breakpoint
- `<leader>dc` - Continue
- `<leader>di` - Step into
- `<leader>do` - Step out
- `<leader>dO` - Step over
- `<leader>du` - Toggle DAP UI

### Git
- `]h/[h` - Next/previous git hunk
- `<leader>ghs` - Stage hunk
- `<leader>ghr` - Reset hunk
- `<leader>gg` - LazyGit
- `<leader>gb` - Git blame

### Mini.nvim Features
- `sa` - Add surrounding
- `sd` - Delete surrounding
- `sr` - Replace surrounding
- `gcc` - Comment line
- `gc` - Comment motion
- `<leader>j` - Jump 2D

## Configuration Structure

```
config/nvim-gpt/
├── init.lua                 # Main entry point
├── lua/
│   ├── config/
│   │   ├── autocmds.lua    # Auto commands
│   │   ├── keymaps.lua     # Key mappings
│   │   └── options.lua     # Neovim options
│   └── plugins/
│       ├── colorscheme.lua # Color schemes
│       ├── completion.lua  # Auto-completion
│       ├── dap.lua        # Debug adapters
│       ├── formatting.lua # Formatting & linting
│       ├── git.lua        # Git integration
│       ├── lsp.lua        # Language servers
│       ├── mini.lua       # Mini.nvim modules
│       ├── snacks.lua     # Snacks.nvim setup
│       ├── telescope.lua  # Fuzzy finder
│       └── treesitter.lua # Syntax highlighting
└── README.md              # This file
```

## Customization

### Adding New Languages
1. **LSP**: Add server configuration to `lua/plugins/lsp.lua`
2. **DAP**: Add debug adapter to `lua/plugins/dap.lua`
3. **Treesitter**: Add parser to `ensure_installed` in `lua/plugins/treesitter.lua`
4. **Formatting**: Add formatter to `lua/plugins/formatting.lua`

### Changing Colorscheme
Edit `lua/plugins/colorscheme.lua` and modify the `config` function to use a different theme:
```lua
vim.cmd.colorscheme("catppuccin") -- or "gruvbox"
```

### Modifying Key Bindings
Key bindings are defined in:
- `lua/config/keymaps.lua` - General key bindings
- Individual plugin files - Plugin-specific bindings

## Language-Specific Setup

### Go
- Install Go tools: `go install golang.org/x/tools/gopls@latest`
- Debug support with Delve is automatically configured

### Zig
- Install ZLS: Follow [ZLS installation guide](https://github.com/zigtools/zls)
- CodeLLDB is used for debugging

### C/C++
- Install clangd: Usually available in system packages
- CodeLLDB provides debugging support

### Lua
- Lua language server is automatically installed via Mason
- Enhanced Neovim API support with neodev

### Shell
- bash-language-server provides LSP support
- shellcheck for linting, shfmt for formatting

## Troubleshooting

### Common Issues
1. **LSP not working**: Run `:Mason` and ensure servers are installed
2. **Treesitter errors**: Run `:TSUpdate` to update parsers
3. **Formatting not working**: Check if formatter is installed via Mason
4. **DAP not working**: Ensure debug adapters are installed (`:Mason`)

### Health Check
Run `:checkhealth` to diagnose common issues.

### Logs
- LSP logs: `:LspLog`
- Plugin manager: `:Lazy`
- Mason: `:Mason`

## Performance

This configuration is optimized for performance:
- Lazy loading of plugins
- Minimal startup time
- Efficient treesitter queries
- Optimized LSP settings

## Contributing

Feel free to submit issues and improvements. When adding new features:
1. Follow the existing code structure
2. Add appropriate documentation
3. Test with multiple languages
4. Ensure lazy loading where appropriate

## License

This configuration is provided as-is for educational and personal use.