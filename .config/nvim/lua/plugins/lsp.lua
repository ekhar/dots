return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        denols = {
          -- LSP workspace is scoped to Deno directories
          root_dir = function(fname)
            local util = require("lspconfig.util")
            local deno_root = util.root_pattern("deno.json", "deno.jsonc")(fname)
            if deno_root then
              return deno_root
            end
            return nil
          end,
          single_file_support = false,
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "json" },
          init_options = {
            lint = true,
            unstable = true,
            suggest = {
              imports = {
                hosts = {
                  ["https://deno.land"] = true,
                  ["https://cdn.nest.land"] = true,
                  ["https://crux.land"] = true,
                },
              },
            },
          },
        },
        vtsls = {
          -- LSP workspace scoped to non-Deno directories
          root_dir = function(fname)
            local util = require("lspconfig.util")
            local deno_root = util.root_pattern("deno.json", "deno.jsonc")(fname)
            if deno_root then
              return nil
            end
            return util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")(fname)
          end,
          single_file_support = false,
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
        },
      },
    },
  },
}
