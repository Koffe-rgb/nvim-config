return {
    "ahmedkhalf/project.nvim",
    init = function()
        require("project_nvim").setup({
            patterns = {
                ".git",
                "*.sln",
                "*.slnx",
                "init.lua",
            },
        })
    end,
}
