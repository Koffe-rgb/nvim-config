return {
    "stevearc/oil.nvim",
    opts = {
        columns = { "icon", "mtime" },
        view_options = { show_hidden = true },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
        { "-", "<cmd>Oil --float<CR>", { desc = "Open parent directory in Oil" } },
    },
}
