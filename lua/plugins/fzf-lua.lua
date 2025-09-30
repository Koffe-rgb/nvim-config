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
            desc = "Fzf: [F]ind [F]iles",
        },
        {
            "<leader>fg",
            function()
                require("fzf-lua").live_grep()
            end,
            desc = "Fzf: [F]ind by [G]repping",
        },
        {
            "<leader><leader>",
            function()
                require("fzf-lua").buffers()
            end,
            desc = "Fzf: [ ] Find in Buffers",
        },
        {
            "<leader>ft",
            function()
                vim.cmd("TodoFzfLua")
            end,
            desc = "Fzf: [F]ind [T]odos",
        },
        {
            "<leader>fh",
            function()
                require("fzf-lua").helptags()
            end,
            desc = "Fzf: [F]ind [H]elp",
        },
        {
            "<leader>da",
            function()
                require("fzf-lua").diagnostics_workspace()
            end,
            desc = "Fzf: Open [D]iagnostics [A]ll",
        },
        {
            "<leader>/",
            function()
                require("fzf-lua").lgrep_curbuf()
            end,
            desc = "Fzf: [/] Live Grep Current Buffer",
        },
        {
            "<leader>q",
            function()
                require("fzf-lua").quickfix()
            end,
            desc = "Fzf: Open [Q]uickfix List",
        },
    },
}
