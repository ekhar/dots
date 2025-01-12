return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        denols = {
          -- Modified root_dir to strictly respect deno.json boundaries
          root_dir = function(fname)
            local util = require("lspconfig.util")
            -- Find the closest deno.json/deno.jsonc from the current file
            local deno_root = util.root_pattern("deno.json", "deno.jsonc")(fname)
            if deno_root then
              -- Only enable Deno LSP if we're within this directory tree
              local relative_path = vim.fn.fnamemodify(fname, ":p"):sub(#deno_root + 1)
              if relative_path:match("^[/\\]") then
                return deno_root
              end
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
          -- Modified root_dir to respect package.json but avoid Deno directories
          root_dir = function(fname)
            local util = require("lspconfig.util")
            -- First check if we're in a Deno project
            local deno_root = util.root_pattern("deno.json", "deno.jsonc")(fname)
            if deno_root then
              return nil -- Don't activate vtsls in Deno directories
            end
            -- Otherwise, look for Node.js/TypeScript project markers
            return util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")(fname)
          end,
          single_file_support = false,
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
        },
      },
    },
  },
}
