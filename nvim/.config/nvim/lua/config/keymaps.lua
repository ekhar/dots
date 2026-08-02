-- Keymaps are loaded on LazyVim's VeryLazy event.
vim.keymap.set("n", "<leader>yA", ":%y+<CR>", {
  desc = "Yank entire buffer",
  silent = true,
})
