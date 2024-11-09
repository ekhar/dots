-- ~/.config/nvim/lua/plugins/eslint.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            -- Enable new flat config support
            experimental = {
              useFlatConfig = true,
            },
          },
        },
      },
    },
  },
}
