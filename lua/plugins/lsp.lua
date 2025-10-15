---- LSP CONFIG ----
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
        "mason-org/mason-lspconfig.nvim",
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
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
            -- NOTE: add servers configurations as needed
            local servers = {
                clangd = require("plugins.lsp.clangd-lsp-configuration"),
                lua_ls = require("plugins.lsp.lua-lsp-configuration"),
                roslyn = require("plugins.lsp.roslyn-lsp-configuration"),
                bashls = {},
            }

            -- extend server capabilities
            local blink = require("blink.cmp")
            local on_attach = require("plugins.lsp.lsp-on-attach")
            for _, config in pairs(servers) do
                config.capabilities = blink.get_lsp_capabilities(config.capabilities)
                config.on_attach = on_attach
            end

            -- install all servers and tools
            local ensure_installed = vim.tbl_keys(servers or {})
            local tools_to_install = require("plugins.lsp.tools-to-install")
            vim.list_extend(ensure_installed, tools_to_install)
            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

            -- configure and enable servers
            for name, config in pairs(servers) do
                vim.lsp.config(name, config)
                vim.lsp.enable(name)
            end
        end,
    },
}
