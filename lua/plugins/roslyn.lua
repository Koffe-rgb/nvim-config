return {
    "seblyng/roslyn.nvim",
    ft = { "cs" },
    opts = {},
    dependencies = {
        {
            "khoido2003/roslyn-filewatch.nvim",
            config = function()
                require("roslyn_filewatch").setup({})
            end,
        },
    },
}
