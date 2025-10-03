return {
    "stevearc/oil.nvim",
    opts = {
        columns = { "icon", "mtime" },
        view_options = { show_hidden = true },
        float = {
            max_width = 0.5,
            max_height = 0.7,
        },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
        { "-", "<cmd>Oil --float<CR>", { desc = "Oil: Open parent directory in Oil" } },
    },
}
