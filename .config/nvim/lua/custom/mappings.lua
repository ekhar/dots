---@type MappingsTable
local M = {}

M.general = {
  n = {
    --  format with conform
    ["<leader>fm"] = {
      function()
        require("conform").format()
      end,
      "formatting",
    },
    -- cycle through buffers
    ["<C-h>"] = {
      function()
        require("nvchad.tabufline").tabuflinePrev()
      end,
      "Goto prev buffer",
    },
    ["<C-l>"] = {
      function()
        require("nvchad.tabufline").tabuflineNext()
      end,
      "Goto next buffer",
    },


  },
  v = {
    [">"] = { ">gv", "indent"},
  },
}

M.copilot = {
  i = {
    ["<C-l>"] = {
      function()
        vim.fn.feedkeys(vim.fn['copilot#Accept'](), '')
      end,
      "Copilot Accept",
      {replace_keycodes = true, nowait=true, silent=true, expr=true, noremap=true}
    }
  },
}

M.dap = {
  n = {
    --create dap shortcuts in the style like above. I want the ["<leader>d{single_key}"]
    ["<leader>dc"] = {
      function()
        require("dap").continue()
      end,
      "Continue",
    },
    ["<leader>db"] = {
      function()
        require("dap").toggle_breakpoint()
      end,
      "Toggle Breakpoint",
    },
    ["<leader>dr"] = {
      function()
        require("dap").repl.open()
      end,
      "Open Repl",
    },
    ["<leader>ds"] = {
      function()
        require("dap").stop()
      end,
      "Stop",
    },
    ["<leader>dn"] = {
      function()
        require("dap").step_over()
      end,
      "Step Over",
    },
    ["<leader>di"] = {
      function()
        require("dap").step_into()
      end,
      "Step Into",
    },
    ["<leader>do"] = {
      function()
        require("dap").step_out()
      end,
      "Step Out",
    },
    ["<leader>dp"] = {
      function()
        require("dap").pause()
      end,
      "Pause",
    },
    ["<leader>dl"] = {
      function()
        require("dap").run_last()
      end,
      "Run Last",
    },
    }
}

-- more keybinds!

return M
