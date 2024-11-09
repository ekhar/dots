return {
  "nvim-neo-tree/neo-tree.nvim",
  optional = true,
  opts = function(_, opts)
    opts.window = opts.window or {}
    opts.window.width = 25 -- Adjust this number to make it smaller
    opts.window.position = "left" -- Change to "left" for traditional file explorer position

    opts.open_files_do_not_replace_types = opts.open_files_do_not_replace_types
      or { "terminal", "Trouble", "qf", "Outline", "trouble" }
    table.insert(opts.open_files_do_not_replace_types, "edgy")
  end,
}
