-- filename: .config/nvim/lua/config/options.lua
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.clipboard = "unnamedplus"
vim.g.snacks_animate = false
vim.g.markdown_fenced_languages = {
  "ts=typescript",
}
