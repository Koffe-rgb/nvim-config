local function is_float_window(window)
    if not vim.api.nvim_win_is_valid(window) then
        return false
    end
    local config = vim.api.nvim_win_get_config(window)
    return config.relative ~= ""
end

local function is_oil_filetype()
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
    return filetype == "oil"
end

local function is_oil_buf_name(buffer)
    if not vim.api.nvim_buf_is_valid(buffer) then
        return false
    end
    local buf_name = vim.api.nvim_buf_get_name(buffer)
    return string.match(buf_name, "oil://") ~= nil
end

local function can_harpoon()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)

    local float_win = is_float_window(win)
    local buf_has_oil_name = is_oil_buf_name(buf)
    local buf_has_oil_ft = is_oil_filetype()
    local can_harpoon = not float_win and not buf_has_oil_name and not buf_has_oil_ft

    if not can_harpoon then
        vim.notify("Can not use harpoon right now", vim.log.levels.WARN)
    end

    return can_harpoon
end

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
                if can_harpoon() then
                    require("harpoon"):list():add()
                end
            end,
            desc = "Harpoon: [A]dd current buffer to Harpoon list",
        },
        {
            "<C-e>",
            function()
                local harpoon = require("harpoon")
                if can_harpoon() then
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end
            end,
            desc = "Harpoon: Toggle quick menu",
        },
        {
            "<C-j>",
            function()
                if can_harpoon() then
                    require("harpoon"):list():next()
                end
            end,
            desc = "Harpoon: Next item",
        },
        {
            "<C-k>",
            function()
                if can_harpoon() then
                    require("harpoon"):list():prev()
                end
            end,
            desc = "Harpoon: Previous item",
        },
        {
            "<M-1>",
            function()
                if can_harpoon() then
                    require("harpoon"):list():select(1)
                end
            end,
            desc = "Harpoon: Select [1]",
        },
        {
            "<M-2>",
            function()
                if can_harpoon() then
                    require("harpoon"):list():select(2)
                end
            end,
            desc = "Harpoon: Select [2]",
        },
        {
            "<M-3>",
            function()
                if can_harpoon() then
                    require("harpoon"):list():select(3)
                end
            end,
            desc = "Harpoon: Select [3]",
        },
        {
            "<M-4>",
            function()
                if can_harpoon() then
                    require("harpoon"):list():select(4)
                end
            end,
            desc = "Harpoon: Select [4]",
        },
    },
}
