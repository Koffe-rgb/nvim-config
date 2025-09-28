-- map leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- for nerd font in terminal
vim.g.have_nerd_font = true
-- don't show mode (shown in status line)
vim.o.showmode = false

-- line numbers
vim.o.number = true
vim.o.relativenumber = true

vim.o.signcolumn = "yes"

-- split new windows with ":help" and other commands below and not on top of current window
vim.o.splitbelow = true
-- split new windows with ":vsplit" to the right of current window and not to the left
vim.o.splitright = true

-- do not wrap up lines
vim.o.wrap = false

-- spaces instead of tabs
vim.o.expandtab = true
-- spaces per tab
vim.o.tabstop = 4
-- tab size with >> and <<
vim.o.shiftwidth = 4

-- enable system clipboard
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

-- indent options
vim.o.breakindent = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smarttab = true

-- save undo history
vim.o.undofile = true

-- case-insensitive searching
vim.o.ignorecase = true
vim.o.smartcase = true

-- remain cursor in the middle of window while scrolling
vim.o.scrolloff = 999

-- allow to select not existing text in visual block mode
vim.o.virtualedit = "block"

-- split new window for substitue (":%s/<match>/<substitue>")
vim.o.inccommand = "split"

-- show which line cursor is on
vim.o.cursorline = false

-- dialog when unsaved changes
vim.o.confirm = true

-- enable true color support
vim.o.termguicolors = true

-- disable command line until needed
vim.o.cmdheight = 0

-- how to show whitespace characters
vim.opt.list = true
vim.opt.listchars = { trail = "·" }

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.g.dotnet_errors_only = true
vim.g.dotnet_show_project_file = false

-- sets compiler as dotnet for csharp files
vim.api.nvim_create_autocmd("FileType", {
    desc = "Sets current compiler to dotnet upon entering .cs file",
    pattern = "cs",
    callback = function()
        vim.cmd("compiler dotnet")
    end,
})

-- textDocument/_vs_onAutoInsert for roslyn and roslyn_ls
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        if not client then
            return
        end

        if client.name ~= "roslyn" and client.name ~= "roslyn_ls" then
            return
        end

        vim.api.nvim_create_autocmd("InsertCharPre", {
            desc = "Roslyn: Trigger an auto insert on '/'.",
            buffer = bufnr,
            callback = function()
                local char = vim.v.char

                if char ~= "/" then
                    return
                end

                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                row, col = row - 1, col + 1
                local uri = vim.uri_from_bufnr(bufnr)

                local params = {
                    _vs_textDocument = { uri = uri },
                    _vs_position = { line = row, character = col },
                    _vs_ch = char,
                    _vs_options = {
                        tabSize = vim.bo[bufnr].tabstop,
                        insertSpaces = vim.bo[bufnr].expandtab,
                    },
                }

                -- NOTE: We should send textDocument/_vs_onAutoInsert request only after
                -- buffer has changed.
                vim.defer_fn(function()
                    client:request(
                        ---@diagnostic disable-next-line: param-type-mismatch
                        "textDocument/_vs_onAutoInsert",
                        params,
                        function(err, result, _)
                            if err or not result then
                                return
                            end

                            vim.snippet.expand(result._vs_textEdit.newText)
                        end,
                        bufnr
                    )
                end, 1)
            end,
        })
    end,
})
