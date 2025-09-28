return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {},
    config = function()
        require("conform").setup({
            async = true,
            formatters_by_ft = {
                cs = { "csharpier_koffe" },
                lua = { "stylua" },
            },
            formatters = {
                csharpier_koffe = {
                    command = "csharpier",
                    args = {
                        "format",
                        "--write-stdout",
                    },
                    to_stdin = true,
                },
            },
            format_on_save = {
                timout_ms = 500,
                lsp_fallback = true,
            },
        })
    end,
}
