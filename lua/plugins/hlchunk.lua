return {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("hlchunk").setup({
            chunk = {
                enable = false,
                delay = 300,
                duration = 0,
                chars = {
                    horizontal_line = "─",
                    vertical_line = "│",
                    left_top = "┌",
                    left_bottom = "└",
                    right_arrow = "─",
                },
            },
            indent = {
                enable = true,
                chars = {
                    "│",
                    "¦",
                    "┆",
                    "┊",
                },
            },
            line_num = {
                enable = false,
            },
            blank = {
                enable = false,
            },
        })
    end,
}
