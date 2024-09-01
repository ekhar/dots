local options = {
	ensure_installed = {
		"maintained",
		"svelte",
		"go",
		"rust",
		"lua",
		"vim",
		"markdown",
		"html",
		"css",
		"javascript",
		"typescript",
		"tsx",
		"json",
		"yaml",
		"toml",
		"python",
		"bash",
		"dockerfile",
		"graphql",
		"markdown_inline",
		"c",
		"cpp",
		"cmake",
		"csharp",
		"java",
		"kotlin",
		"php",
		"perl",
		"powershell",
		"ruby",
		"sql",
		"swift",
		"verilog",
		"vue",
		"xml",
		"zig",
	},

	highlight = {
		enable = true,
		use_languagetree = true,
	},
	autopairs = { enable = true },

	indent = { enable = true },
	--[[ context_commentstring = { ]]
	--[[   enable = true, ]]
	--[[   enable_autocmd = false, ]]
	--[[ }, ]]
}

return options
