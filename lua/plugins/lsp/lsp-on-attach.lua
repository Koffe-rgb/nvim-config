local function client_supports_method(client, method, bufnr)
    if vim.fn.has("nvim-0.11") == 1 then
        return client:supports_method(method, bufnr)
    else
        return client.supports_method(method, { bufnr = bufnr })
    end
end

local map = function(buf, keys, func, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, keys, func, {
        buffer = buf,
        desc = "LSP: " .. desc,
        noremap = true,
        silent = true,
    })
end

local function enable_code_lens()
    local codelens_augroup = vim.api.nvim_create_augroup("LSPCodeLens", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = codelens_augroup,
        callback = function(args)
            if not vim.g.codelens_enabled then
                return
            end

            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave", "TextChanged" }, {
                group = codelens_augroup,
                buffer = bufnr,
                callback = function()
                    -- Use defer to avoid refreshing too frequently
                    vim.defer_fn(function()
                        vim.lsp.codelens.refresh({ bufnr = bufnr })
                    end, 100)
                end,
                desc = "Refresh LSP code lenses",
            })

            -- Initial refresh after a short delay
            vim.defer_fn(function()
                vim.lsp.codelens.refresh({ bufnr = bufnr })
            end, 500)
        end,
    })
end

local function enable_highlights(buf)
    local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
        callback = function(args)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = args.buf })
        end,
    })
end

return function(client, buf)
    map(buf, "<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map(buf, "<leader>fm", require("conform").format, "[F]or[m]at code in file")
    map(buf, "<leader>ca", require("fzf-lua").lsp_code_actions, "[C]ode [A]ctions", { "n", "x" })
    map(buf, "<leader>gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")
    map(buf, "<leader>gi", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")
    map(buf, "<leader>gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")
    map(buf, "<leader>gt", require("fzf-lua").lsp_typedefs, "[G]oto [T]ype Definition")
    map(buf, "K", function()
        vim.lsp.buf.hover({ border = "single" })
    end, "Hover Documentation")

    local document_highlights = true
        and client
        and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, buf)

    if document_highlights then
        enable_highlights(buf)
    end

    local inlay_hints = true
        and vim.g.inlay_hints_enabled
        and client
        and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, buf)

    if inlay_hints then
        vim.lsp.inlay_hint.enable(true, { bufnr = buf })
        map(buf, "<leader>th", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
            vim.lsp.inlay_hint.enable(not enabled)
        end, "[T]oggle Inlay [H]ints")
    end

    local code_lens = true
        and vim.g.codelens_enabled
        and client
        and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_codeLens, buf)

    if code_lens then
        enable_code_lens()
    end
end
