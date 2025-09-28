---- LSP CONFIG ----

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

        local function client_supports_method(client, method, bufnr)
            if vim.fn.has("nvim-0.11") == 1 then
                return client:supports_method(method, bufnr)
            else
                return client.supports_method(method, { bufnr = bufnr })
            end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map("<leader>th", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
        end
    end,
})

-- diagnostics
vim.diagnostic.config({
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    } or {},
    -- Disabled for tiny-inline-diagnostics
    -- virtual_text = {
    --     source = "if_many",
    --     spacing = 2,
    --     format = function(diagnostic)
    --         local diagnostic_message = {
    --             [vim.diagnostic.severity.ERROR] = diagnostic.message,
    --             [vim.diagnostic.severity.WARN] = diagnostic.message,
    --             [vim.diagnostic.severity.INFO] = diagnostic.message,
    --             [vim.diagnostic.severity.HINT] = diagnostic.message,
    --         }
    --         return diagnostic_message[diagnostic.severity]
    --     end,
    -- },
})

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "mason-org/mason.nvim",
            opts = {
                registries = {
                    "github:mason-org/mason-registry",
                    "github:Crashdummyy/mason-registry",
                },
            },
        },
        "mason-org/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "saghen/blink.cmp",
        "ibhagwan/fzf-lua",
        "stevearc/conform.nvim",
    },
    config = function()
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        local servers = {
            clangd = require("plugins.lsp.clangd"),
            lua_ls = require("plugins.lsp.lua_ls"),
            roslyn = require("plugins.lsp.roslyn"),
        }

        local ensure_installed = vim.tbl_keys(servers or {})
        local tools = require("plugins.lsp.tools")

        vim.list_extend(ensure_installed, tools)
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        require("mason-lspconfig").setup({
            ensure_installed = {},
            automatic_installation = false,
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                    vim.lsp.config(server_name, server)
                end,
            },
        })
    end,
}
