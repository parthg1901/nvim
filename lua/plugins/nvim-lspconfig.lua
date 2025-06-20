local on_attach = require("util.lsp").on_attach
local diagnostic_signs = require("util.icons").diagnostic_signs
local typescript_organise_imports = require("util.lsp").typescript_organise_imports

local config = function()
    require("neoconf").setup({})
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local lspconfig = require("lspconfig")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Solidity LSP
    lspconfig.solidity_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = {"solidity"},
        root_dir = lspconfig.util.root_pattern("hardhat.config.*", "foundry.toml", "remappings.txt", ".git"),
        settings = {
            solidity = {
                compileUsingRemoteVersion = "v0.8.28+commit.7893614a",
                defaultCompiler = "remote",
                enabledAsYouTypeCompilationErrorCheck = true
            }
        }
    })

    -- Forge Formatter
    local forge_fmt = {
        formatCommand = "forge fmt --raw --check --",
        formatStdin = true
    }

    -- EFM for Solidity
    lspconfig.efm.setup({
        filetypes = {"solidity"},
        on_attach = on_attach,
        root_dir = lspconfig.util.root_pattern("hardhat.config.*", "foundry.toml", "remappings.txt", ".git"),
        init_options = {
            documentFormatting = true,
            codeAction = true
        },
        settings = {
            languages = {
                solidity = {{
                    lintStdin = true,
                    lintIgnoreExitCode = true,
                    lintCommand = "solhint stdin",
                    lintFormats = {" %#%l:%c %#%tarning %#%m", " %#%l:%c %#%trror %#%m"},
                    lintSource = "solhint"
                }, forge_fmt}
            }
        }
    })

    -- Lua LSP
    lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            Lua = {
                workspace = {
                    checkThirdParty = false
                },
                telemetry = {
                    enable = false
                },
                diagnostics = {
                    globals = {"vim"}
                }
            }
        }
    })

    -- JSON LSP
    lspconfig.jsonls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            json = {
                schemas = require("schemastore").json.schemas(),
                validate = {
                    enable = true
                }
            }
        }
    })

    -- TypeScript/JavaScript LSP (vtsls)
    lspconfig.vtsls.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            on_attach(client, bufnr)
            
            -- Custom vtsls commands
            client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
                ---@type string, string, lsp.Range
                local action, uri, range = unpack(command.arguments)

                local function move(newf)
                    client.request("workspace/executeCommand", {
                        command = command.command,
                        arguments = { action, uri, range, newf },
                    })
                end

                local fname = vim.uri_to_fname(uri)
                client.request("workspace/executeCommand", {
                    command = "typescript.tsserverRequest",
                    arguments = {
                        "getMoveToRefactoringFileSuggestions",
                        {
                            file = fname,
                            startLine = range.start.line + 1,
                            startOffset = range.start.character + 1,
                            endLine = range["end"].line + 1,
                            endOffset = range["end"].character + 1,
                        },
                    },
                }, function(_, result)
                    ---@type string[]
                    local files = result.body.files
                    table.insert(files, 1, "Enter new path...")
                    vim.ui.select(files, {
                        prompt = "Select move destination:",
                        format_item = function(f)
                            return vim.fn.fnamemodify(f, ":~:.")
                        end,
                    }, function(f)
                        if f and f:find("^Enter new path") then
                            vim.ui.input({
                                prompt = "Enter move destination:",
                                default = vim.fn.fnamemodify(fname, ":h") .. "/",
                                completion = "file",
                            }, function(newf)
                                return newf and move(newf)
                            end)
                        elseif f then
                            move(f)
                        end
                    end)
                end)
            end
        end,
        filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
        },
        settings = {
            complete_function_calls = true,
            vtsls = {
                enableMoveToFileCodeAction = true,
                autoUseWorkspaceTsdk = true,
                experimental = {
                    maxInlayHintLength = 30,
                    completion = {
                        enableServerSideFuzzyMatch = true,
                    },
                },
            },
            typescript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                    completeFunctionCalls = true,
                },
                inlayHints = {
                    enumMemberValues = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    parameterNames = { enabled = "literals" },
                    parameterTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    variableTypes = { enabled = false },
                },
            },
            javascript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                    completeFunctionCalls = true,
                },
                inlayHints = {
                    enumMemberValues = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    parameterNames = { enabled = "literals" },
                    parameterTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    variableTypes = { enabled = false },
                },
            },
        },
    })

    -- Diagnostic Signs
    for type, icon in pairs(diagnostic_signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, {
            text = icon,
            texthl = hl,
            numhl = ""
        })
    end
end

return {
    "neovim/nvim-lspconfig",
    config = config,
    lazy = false,
    dependencies = {
        "williamboman/mason.nvim", 
        "creativenull/efmls-configs-nvim", -- only needed if using EFM formatters
        "hrsh7th/cmp-nvim-lsp", 
        "b0o/schemastore.nvim",
        "yioneko/nvim-vtsls", -- TypeScript Language Server
    }
}
