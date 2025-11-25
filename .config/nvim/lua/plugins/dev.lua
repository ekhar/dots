-- filename: .config/nvim/lua/plugins/dev.lua
return {
  {
    dir = "/Users/eric/dots/.config/filename_cc.nvim/", -- path to the plugin
    config = function()
      -- This works because the plugin has lua/nvim-filename-plugin/init.lua
      require("filename_cc").setup()
    end,
  },
}
