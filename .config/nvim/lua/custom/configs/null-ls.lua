local null_ls = require("null-ls")


local opts = {
  sources = {
    null_ls.builtins.formatting.prettierd,
    -- null_ls.builtins.formatting.stylua,
    -- null_ls.builtins.formatting.eslint,
    -- null_ls.builtins.formatting.spell,

  }
}
return opts
