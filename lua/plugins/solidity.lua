local on_attach = require("util.lsp").on_attach
local diagnostic_signs = require("util.icons").diagnostic_signs

local config = function()
	require("neoconf").setup({})
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local lspconfig = require("lspconfig")
	local capabilities = cmp_nvim_lsp.default_capabilities()

	-- Solidity LSP
	lspconfig.solidity_ls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "solidity" },
		root_dir = lspconfig.util.root_pattern("hardhat.config.*", "foundry.toml", "remappings.txt", ".git"),
		settings = {
			solidity = {
				compileUsingRemoteVersion = 'v0.8.28+commit.7893614a',
				defaultCompiler = 'remote',
				enabledAsYouTypeCompilationErrorCheck = true,
			},
		}
	})

	-- Formatter & Linter for Solidity
	local solhint = require("efmls-configs.linters.solhint")
	local prettier_d = require("efmls-configs.formatters.prettier_d")

	lspconfig.efm.setup({
		filetypes = { "solidity" },
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = true,
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},
		settings = {
			languages = {
				solidity = { solhint, prettier_d },
			},
		},
	})

	-- Set diagnostic signs
	for type, icon in pairs(diagnostic_signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	lazy = false,
	dependencies = {
		"williamboman/mason.nvim",
		"creativenull/efmls-configs-nvim",
		"hrsh7th/cmp-nvim-lsp",
	},
}
