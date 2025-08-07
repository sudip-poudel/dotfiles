# My Custom Neovim Setup

This is a custom Neovim configuration inspired by LazyVim but built from scratch without the LazyVim dependency. It includes all the essential features you requested.

## Features

- **Full LSP Setup**: Complete Language Server Protocol support with automatic server installation via Mason
- **Blink.cmp**: Fast and feature-rich completion engine
- **Lualine**: Beautiful and informative statusline
- **Treesitter**: Syntax highlighting and code understanding
- **Telescope**: Fuzzy finder for files, buffers, and more
- **Neo-tree**: Modern file explorer with git integration
- **Alpha Dashboard**: Beautiful startup screen with quick actions
- **Aerial**: Code outline and navigation window
- **GitHub Copilot**: AI-powered code completion and chat
- **Git Integration**: Complete git workflow with signs, hunks, blame, diff, staging, and more
- **Which-key**: Key binding help
- **Trouble**: Better diagnostics and quickfix lists
- **Auto-pairs**: Automatic bracket/quote pairing
- **Surround**: Easy text surrounding operations
- **Flash**: Enhanced navigation and searching
- **Todo Comments**: Highlight TODO, FIXME, etc.
- **Code Formatting**: Automatic formatting with conform.nvim and format-on-save
- **TokyoNight**: Beautiful color scheme

## Installation

1. **Backup your existing Neovim configuration** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Copy this configuration**:
   ```bash
   cp -r /path/to/mysetu ~/.config/nvim
   ```

3. **Start Neovim**:
   ```bash
   nvim
   ```

4. **Wait for plugins to install**: Lazy.nvim will automatically install all plugins on first startup.

5. **Install LSP servers**: Run `:Mason` to see available language servers and install the ones you need.

## Key Mappings

### General
- `<Space>` - Leader key
- `<C-s>` - Save file
- `<C-h/j/k/l>` - Navigate windows
- `<S-h/l>` - Switch buffers
- `<A-j/k>` - Move lines up/down

### LSP (when attached)
- `gd` - Go to definition
- `gr` - Go to references  
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>cr` - Rename symbol
- `<leader>cf` - Format document
- `<leader>cF` - Format injected languages

### File Operations
- `<leader><space>` - Find files
- `<leader>/` - Search in project
- `<leader>ff` - Find files
- `<leader>fb` - Find buffers
- `<leader>fr` - Recent files
- `<leader>e` or `<leader>fe` - File Explorer (Neo-tree)
- `<leader>E` or `<leader>fE` - File Explorer (current file dir)
- `<leader>ge` - Git Explorer
- `<leader>be` - Buffer Explorer

### Git
- `]h/[h` - Next/previous hunk
- `]H/[H` - Last/first hunk
- `<leader>ghs` - Stage hunk
- `<leader>ghr` - Reset hunk
- `<leader>ghS` - Stage buffer
- `<leader>ghu` - Undo stage hunk
- `<leader>ghR` - Reset buffer
- `<leader>ghp` - Preview hunk inline
- `<leader>ghb` - Blame line
- `<leader>ghB` - Blame buffer
- `<leader>ghd` - Diff this
- `<leader>ghD` - Diff this ~
- `ih` - GitSigns select hunk (text object)

### Diagnostics
- `]d/[d` - Next/previous diagnostic
- `<leader>xx` - Open Trouble diagnostics
- `<leader>cd` - Show line diagnostics
- `<leader>cs` - Symbols outline (Aerial)

### AI (GitHub Copilot)
- `<C-j>` - Accept Copilot suggestion (insert mode)
- `<C-h>` - Dismiss Copilot suggestion (insert mode)
- `<C-n/p>` - Next/previous suggestion (insert mode)
- `<leader>ai` - Ask Copilot (custom input)
- `<leader>aq` - Quick chat with Copilot
- `<leader>ae` - Explain code
- `<leader>at` - Generate tests
- `<leader>ar` - Review code
- `<leader>aR` - Refactor code
- `<leader>an` - Better naming suggestions
- `<leader>af` - Fix diagnostic with AI
- `<leader>am` - Generate commit message
- `<leader>av` - Visual chat (visual mode)
- `<leader>ah` - Help actions
- `<leader>ap` - Prompt actions

### Toggle Options
- `<leader>us` - Toggle spelling
- `<leader>uw` - Toggle word wrap
- `<leader>ul` - Toggle line numbers
- `<leader>ud` - Toggle diagnostics

## Customization

### Adding Language Servers

Edit `lua/plugins/lsp.lua` and add your server to the `servers` table:

```lua
servers = {
  -- Add your servers here
  pyright = {},  -- Python
  tsserver = {}, -- TypeScript
  -- etc.
}
```

### Changing Colorscheme

Edit `lua/plugins/colorscheme.lua` to use a different theme or modify TokyoNight settings.

### Adding Plugins

Create new files in `lua/plugins/` or add to existing files. For example, to add a new plugin:

```lua
return {
  {
    "your-plugin/name",
    config = function()
      -- Plugin configuration
    end,
  },
}
```

### Modifying Keymaps

Edit `lua/config/keymaps.lua` to add or modify key mappings.

### Changing Options

Edit `lua/config/options.lua` to modify Neovim settings.

## Directory Structure

```
nvim/
├── init.lua                    # Main entry point
└── lua/
    ├── config/
    │   ├── autocmds.lua       # Auto commands
    │   ├── keymaps.lua        # Key mappings
    │   └── options.lua        # Neovim options
    └── plugins/
        ├── ai.lua             # GitHub Copilot & Copilot Chat
        ├── coding.lua         # Coding utilities
        ├── colorscheme.lua    # Color scheme
        ├── completion.lua     # Blink.cmp setup
        ├── dashboard.lua      # Alpha dashboard
        ├── editor.lua         # Editor plugins (Neo-tree, Aerial, etc.)
        ├── formatting.lua     # Code formatting
        ├── lsp.lua           # LSP configuration
        ├── treesitter.lua    # Treesitter setup
        └── ui.lua            # UI plugins (lualine)
```

## Tips

1. Use `:Lazy` to manage plugins
2. Use `:Mason` to install/manage LSP servers, formatters, and linters
3. Use `:Telescope` or `<leader>/` to search within your project
4. Use `<leader>xx` to see all diagnostics in a nice list
5. The configuration is modular - you can easily remove plugins you don't need

## Troubleshooting

If you encounter issues:

1. Run `:checkhealth` to see if there are any problems
2. Run `:Lazy sync` to update plugins
3. Run `:Mason` to ensure LSP servers are installed
4. Check the Neovim logs with `:messages`

Enjoy your new Neovim setup!
