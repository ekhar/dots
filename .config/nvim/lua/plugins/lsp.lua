return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Deno LSP configuration
        denols = {
          root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc"),
          -- Explicitly disable single file support
          single_file_support = false,
          -- Configure file types explicitly
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
        -- TypeScript LSP configuration (vtsls in your case)
        vtsls = {
          root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json", "jsconfig.json"),
          single_file_support = false,
          -- Ensure TypeScript tools don't activate in Deno projects
          root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
          -- Configure file types explicitly
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
        },
      },
    },
  },
}
