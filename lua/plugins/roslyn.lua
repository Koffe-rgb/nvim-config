local function create_autocmd_to_ask_for_diagnotics()
    vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        pattern = "*",
        callback = function()
            local clients = vim.lsp.get_clients({ name = "roslyn" })
            if not clients or #clients == 0 then
                return
            end

            local client = clients[1]
            local buffers = vim.lsp.get_buffers_by_client_id(client.client_id)
            for _, buf in ipairs(buffers) do
                local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
                client:request(vim.lsp.protocol.Methods.textDocument_diagnostic, params, nil, buf)
            end
        end,
    })
end

local function create_autocmd_vs_onAutoInsert()
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
end

return {
    "seblyng/roslyn.nvim",
    ft = { "cs", "csproj", "sln", "slnx" },
    opts = {
        filewatchinh = "roslyn",
    },
    init = function()
        -- ask for diagnostics every time we leave insert mode
        create_autocmd_to_ask_for_diagnotics()

        -- textDocument/_vs_onAutoInsert for roslyn and roslyn_ls
        create_autocmd_vs_onAutoInsert()
    end,
}
