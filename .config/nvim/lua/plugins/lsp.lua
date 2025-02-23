-- filename: .config/nvim/lua/plugins/lsp.lua
local nvim_lsp = require("lspconfig")

-- Specialized root pattern that allows for an exclusion
---@param opt { root: string[], exclude: string[] }
---@return fun(file_name: string): string | nil
local function root_pattern_exclude(opt)
  return function(fname)
    local excluded_root = nvim_lsp.util.root_pattern(unpack(opt.exclude))(fname)
    local included_root = nvim_lsp.util.root_pattern(unpack(opt.root))(fname)
    if excluded_root then
      return nil
    else
      return included_root
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        denols = {
          filetypes = { "typescript", "typescriptreact" },
          root_dir = nvim_lsp.util.root_pattern("deno.jsonc", "deno.json"),
          init_options = {
            lint = true,
            suggest = {
              imports = {
                hosts = {
                  ["https://deno.land"] = true,
                },
              },
            },
          },
        },
        tsserver = {
          root_dir = root_pattern_exclude({
            root = { "package.json" },
            exclude = { "deno.json", "deno.jsonc" },
          }),
          single_file_support = false,
        },
        vtsls = {
          root_dir = function()
            return not vim.fs.root(0, { "deno.json", "deno.jsonc" })
              and vim.fs.root(0, {
                "tsconfig.json",
                "jsconfig.json",
                "package.json",
                ".git",
              })
          end,
          single_file_support = false,
        },
      },
    },
  },
}
