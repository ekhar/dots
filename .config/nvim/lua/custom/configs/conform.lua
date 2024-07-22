--type conform.options
local options = {
	lsp_fallback = true,

	formatters_by_ft = {
		lua = { "stylua" },

		javascript = { "prettierd" },
		css = { "prettierd" },
		html = { "prettierd" },

		sh = { "shfmt" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    rust = { "rustfmt" },
    python = { "black" },
    go = { "gofmt" },
    json = { "json_tool" },
    yaml = { "yamllint" },
    toml = { "tomllint" },
    markdown = { "prettierd" },
    typescript = {"prettierd"},

	},

  -- adding same formatter for multiple filetypes can look too much work for some
  -- instead of the above code you could just use a loop! the config is just a table after all!

	format_on_save = {
	  -- These options will be passed to conform.format()
	  -- timeout_ms = 50,
	  lsp_fallback = true,
	},
}

require("conform").setup(options)
