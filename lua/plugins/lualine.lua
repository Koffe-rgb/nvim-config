-- Check if LSP client supports method
local function client_supports_method(client, method, bufnr)
    if vim.fn.has("nvim-0.11") == 1 then
        return client:supports_method(method, bufnr)
    else
        return client.supports_method(method, { bufnr = bufnr })
    end
end

-- Get LSP name for status line. Ignores non LSPs (formatters, linters, etc.)
-- If more than one client is attached to current buffer,
-- returns first client name and number of the rest clients
local function get_lsp_name()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if not clients or #clients == 0 then
        return ""
    end

    -- go through all clients attached to current buffer
    -- and filter out non-LSP clients (formatters, linters, etc.)
    -- then add to the list
    local lsp_clients = {}
    for _, client in ipairs(clients) do
        if
            -- if client supports completion or definition or hover method
            -- then it is likely the actual LSP client
            client_supports_method(client, vim.lsp.protocol.Methods.textDocument_completion, 0)
            or client_supports_method(client, vim.lsp.protocol.Methods.textDocument_definition, 0)
            or client_supports_method(client, vim.lsp.protocol.Methods.textDocument_hover, 0)
        then
            table.insert(lsp_clients, client.name)
        end
    end

    if #lsp_clients == 0 then
        -- display nothing if there's no LSP clients
        return ""
    elseif #lsp_clients == 1 then
        -- display LSP name if exactly one client attached
        return "[" .. lsp_clients[1] .. "]"
    else
        -- display LSP name of first client and number of the rest clients
        -- format: [lsp_name + 2]
        return "[" .. lsp_clients[1] .. " +" .. (#lsp_clients - 1) .. "]"
    end
end

-- Get encoding for status line.
-- Return nothing if it's utf-8 to reduce visual noise
local function get_encoding_filtered()
    local ret, _ = (vim.bo.fenc or vim.go.enc):gsub("^utf%-8$", "")
    return ret
end

-- Get file format for status line.
-- Return nothing if it's unix (LF) file format to reduce visual noise
local function get_file_format_filtered()
    local ret, _ = vim.bo.fileformat:gsub("^unix$", "")
    return ret
end

-- Get Solution name for status line.
-- Works only with roslyn.nvim plugin. Returns nothing if there's no selected solution
local function get_solution_name()
    local solution_path = vim.g.roslyn_nvim_selected_solution
    local solution_name = " " .. solution_path:match("([^/\\]+)$")
    return solution_name or ""
end

return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        options = {
            theme = "onedark",
            component_separators = "│",
            section_separators = "",
        },
        sections = {
            lualine_b = {
                {
                    get_solution_name,
                    icon = "󰘐",
                },
                "branch",
                {
                    "diff",
                    symbols = {
                        added = " ",
                        modified = " ",
                        removed = " ",
                    },
                },
                "diagnostics",
            },
            lualine_x = {
                {
                    get_lsp_name,
                    icon = "",
                },
                get_encoding_filtered,
                get_file_format_filtered,
                "filetype",
            },
        },
    },
}
