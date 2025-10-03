return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
        indent = {
            char = {
                "│",
                "¦",
                "┆",
                "┊",
            },
            highlight = "IblScope",
        },
        scope = {
            enabled = false,
        },
    },
}
