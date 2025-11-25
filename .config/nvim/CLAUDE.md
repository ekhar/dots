# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

LazyVim-based Neovim configuration. Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management with LazyVim as the base distribution.

## Structure

```
lua/
├── config/
│   ├── lazy.lua      # Plugin manager bootstrap and setup
│   ├── options.lua   # Vim options (loaded before plugins)
│   ├── keymaps.lua   # Custom keymaps (loaded on VeryLazy)
│   └── autocmds.lua  # Custom autocommands (loaded on VeryLazy)
└── plugins/          # Plugin specs (auto-loaded by lazy.nvim)
```

## Adding/Modifying Plugins

Create or edit files in `lua/plugins/`. Each file returns a table of plugin specs:

```lua
return {
  {
    "author/plugin-name",
    opts = { ... },  -- Merged with defaults
  },
}
```

To override LazyVim defaults, use the same plugin name with new opts. To disable a plugin: `{ "plugin-name", enabled = false }`.

## Key Customizations

- **Theme**: Tokyo Night (moon style) - configured in `theme.lua`
- **Supermaven**: AI completion with `<C-l>` accept, `<C-j>` accept word
- **Neo-tree**: Width 25, left position
- **Rustaceanvim**: Enhanced Rust LSP support
- **VSCode mode**: Reduced plugin set when running as VSCode backend (`vscode.lua`)
- **Local plugin**: `filename_cc.nvim` loaded from `~/.config/filename_cc.nvim/`

## Custom Keymaps

- `<C-c>` (normal): Copy entire buffer to clipboard

## Options

- Clipboard: Uses system clipboard (`unnamedplus`)
- Animations: Disabled (`snacks_animate = false`)
