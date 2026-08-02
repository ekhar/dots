# Neovim

A small LazyVim configuration focused on TypeScript, Rust, infrastructure files, and Markdown.

## Design

- LazyVim provides editor defaults and plugin wiring.
- Snacks provides both picking and file exploration.
- Biome is the preferred formatter for supported JavaScript and TypeScript projects.
- Language tooling is selected through `lazyvim.json` extras.
- `lazy-lock.json` is committed so installs are reproducible.

## Commands

```bash
nvim                    # open the editor
nvim --headless '+Lazy! sync' +qa
nvim --headless '+checkhealth' +qa
stylua --check lua
```

For Rust projects, install the toolchain language server once:

```bash
rustup component add rust-analyzer
```

Custom mappings:

| Mapping       | Action                                         |
| ------------- | ---------------------------------------------- |
| `<leader>yA`  | Copy the entire buffer to the system clipboard |
