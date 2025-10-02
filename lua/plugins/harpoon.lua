return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("harpoon").setup({})
    end,
    keys = {
        {
            "<leader>a",
            function()
                require("harpoon"):list():add()
            end,
            desc = "Harpoon: [A]dd current buffer to Harpoon list",
        },
        {
            "<C-e>",
            function()
                local harpoon = require("harpoon")
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = "Harpoon: Toggle quick menu",
        },
        {
            "<C-j>",
            function()
                require("harpoon"):list():next()
            end,
            desc = "Harpoon: Next item",
        },
        {
            "<C-k>",
            function()
                require("harpoon"):list():prev()
            end,
            desc = "Harpoon: Previous item",
        },
        {
            "<M-1>",
            function()
                require("harpoon"):list():select(1)
            end,
            desc = "Harpoon: Select [1]",
        },
        {
            "<M-2>",
            function()
                require("harpoon"):list():select(2)
            end,
            desc = "Harpoon: Select [2]",
        },
        {
            "<M-3>",
            function()
                require("harpoon"):list():select(3)
            end,
            desc = "Harpoon: Select [3]",
        },
        {
            "<M-4>",
            function()
                require("harpoon"):list():select(4)
            end,
            desc = "Harpoon: Select [4]",
        },
    },
}
