return {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
        require("tiny-inline-diagnostic").setup({
            preset = "simple",
            options = {
                show_all_diags_on_cursorline = true,
                use_icons_from_diagnostic = true,
            },
        })
        vim.diagnostic.config({ virtual_text = false }) -- Disable default virtual text
    end,
}
