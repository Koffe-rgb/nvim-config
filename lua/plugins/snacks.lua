return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        input = { enabled = true },
        picker = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scroll = { enabled = true },
        zen = {
            toggles = {
                dim = false,
            },
        },
    },
    keys = {
        {
            "<leader>n",
            function()
                require("snacks").notifier.show_history()
            end,
            desc = "Show [N]otification history",
        },
        {
            "<leader>z",
            function()
                require("snacks").zen.zen()
            end,
            desc = "[Z]en mode",
        },
    },
}
