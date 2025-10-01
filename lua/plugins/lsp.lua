---- LSP CONFIG ----

local function client_supports_method(client, method, bufnr)
    if vim.fn.has("nvim-0.11") == 1 then
        return client:supports_method(method, bufnr)
    else
        return client.supports_method(method, { bufnr = bufnr })
    end
end

-- map keybindings
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("DefaultLspAttach", { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>fm", require("conform").format, "[F]or[m]at code in file")
        map("<leader>ca", require("fzf-lua").lsp_code_actions, "[C]ode [A]ctions", { "n", "x" })
        map("<leader>gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")
        map("<leader>gi", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")
        map("<leader>gt", require("fzf-lua").lsp_typedefs, "[G]oto [T]ype Definition")
        map("K", vim.lsp.buf.hover, "Hover Documentation")

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if
            client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
        then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                end,
            })
        end

        if
            vim.g.inlay_hints_enabled
            and client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
        then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            map("<leader>th", function()
                local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
                vim.lsp.inlay_hint.enable(not enabled)
            end, "[T]oggle Inlay [H]ints")
        end

        if
            vim.g.codelens_enabled
            and client
            and client_supports_method(client, vim.lsp.protocol.Methods.codeLens_resolve, event.buf)
        then
            map("<leader>cl", function()
                vim.lsp.codelens.run()
            end, "[C]ode [L]ens Action")
        end
    end,
})

-- turn on code lens
if vim.g.codelens_enabled then
    local codelens_augroup = vim.api.nvim_create_augroup("LSPCodeLens", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = codelens_augroup,
        callback = function(event)
            if not vim.g.codelens_enabled then
                return
            end

            local bufnr = event.buf
            local client = vim.lsp.get_client_by_id(event.data.client_id)

            if
                vim.g.codelens_enabled
                and client
                and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_codeLens, bufnr)
            then
                -- Refresh code lenses
                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave", "TextChanged" }, {
                    group = codelens_augroup,
                    buffer = bufnr,
                    callback = function()
                        -- Use defer to avoid refreshing too frequently
                        vim.defer_fn(function()
                            vim.lsp.codelens.refresh({ bufnr = bufnr })
                        end, 100)
                    end,
                    desc = "Refresh LSP code lenses",
                })

                -- Initial refresh after a short delay
                vim.defer_fn(function()
                    vim.lsp.codelens.refresh({ bufnr = bufnr })
                end, 500)
            end
        end,
    })
end

return {
    {
        "mason-org/mason.nvim",
        opts = {
            registries = {
                "github:mason-org/mason-registry",
                "github:Crashdummyy/mason-registry",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            "saghen/blink.cmp",
            "ibhagwan/fzf-lua",
            "stevearc/conform.nvim",
        },
        config = function()
            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- NOTE: add servers configurations as needed
            local server_configurations = {
                clangd = require("plugins.lsp.clangd-lsp"),
                lua_ls = require("plugins.lsp.lua_ls-lsp"),
                roslyn = require("plugins.lsp.roslyn-lsp"),
            }

            local ensure_installed = vim.tbl_keys(server_configurations or {})
            local tools = require("plugins.lsp.tools")
            vim.list_extend(ensure_installed, tools)
            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

            for _, lang in ipairs(vim.tbl_keys(server_configurations)) do
                local configuration = server_configurations[lang] or {}
                configuration.capabilities =
                    vim.tbl_deep_extend("force", {}, capabilities, configuration.capabilities or {})
                vim.lsp.config(lang, configuration)
                vim.lsp.enable(lang)
            end

            -- require("mason-lspconfig").setup({
            --     ensure_installed = {},
            --     automatic_installation = false,
            --     handlers = {
            --         function(server_name)
            --             local server = servers[server_name] or {}
            --             server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            --             require("lspconfig")[server_name].setup(server)
            --             vim.lsp.config(server_name)
            --             -- vim.lsp.config(server_name, server)
            --         end,
            --     },
            -- })
        end,
    },
}
