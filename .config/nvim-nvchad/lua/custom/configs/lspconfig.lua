local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- if you just want default config for the servers then put them in a table
local servers = {
	"html",
	"cssls",
	"tsserver",
	"clangd",
	"pyright",
	"rust_analyzer",
	"jsonls",
	"yamlls",
	"denols",
	"bashls",
	"dockerls",
	"gopls",
	"sqlls",
	"svelte",
	"tailwindcss",
	"eslint",
}

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

lspconfig.clangd.setup({
	on_attach = function(client, bufnr)
		client.server_capablities.signatureHelpProvider = false
		on_attach(client, bufnr)
	end,
	capabilities = capabilities,
	cmd = {
		"clangd",
		"--offset-encoding=utf-16",
		"--suggest-missing-includes",
	},
})

lspconfig.denols.setup({
	on_attach = on_attach,
	root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
})

lspconfig.tsserver.setup({
	on_attach = on_attach,
	root_dir = lspconfig.util.root_pattern("package.json"),
	single_file_support = false,
})

-- lspconfig.gopls.setup({
-- 	settings = {
-- 		gopls = {
-- 			buildFlags = { "-tags=js,wasm" },
-- 			env = {
-- 				GOARCH = "wasm",
-- 				GOOS = "js",
-- 			},
-- 		},
-- 	},
-- })

--
--
-- lspconfig.pyright.setup { blabla}
