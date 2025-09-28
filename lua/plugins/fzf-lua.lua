return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
        {
            "<leader>ff",
            function()
                require("fzf-lua").files()
            end,
            desc = "[F]ind [F]iles",
        },
        {
            "<leader>fg",
            function()
                require("fzf-lua").live_grep()
            end,
            desc = "[F]ind by [G]repping",
        },
        {
            "<leader><leader>",
            function()
                require("fzf-lua").buffers()
            end,
            desc = "[ ] Find in Buffers",
        },
        {
            "<leader>ft",
            function()
                vim.cmd("TodoFzfLua")
            end,
            desc = "[F]ind [T]odos",
        },
        {
            "<leader>fh",
            function()
                require("fzf-lua").helptags()
            end,
            desc = "[F]ind [H]elp",
        },
        {
            "<leader>ds",
            function()
                require("fzf-lua").diagnostics_workspace()
            end,
            desc = "Open [D]iagnostics of Work[S]pace",
        },
        {
            "<leader>/",
            function()
                require("fzf-lua").lgrep_curbuf()
            end,
            desc = "[/] Live Grep Current Buffer",
        },
    },
}
