return {
    "seblyng/roslyn.nvim",
    ft = { "cs", "csproj", "sln", "slnx" },
    opts = {
        filewatchinh = "roslyn",
        settings = {
            ["csharp|background_analysis"] = {
                dotnet_analyzer_diagnostics_scope = "fullSolution",
                dotnet_compiler_diagnostics_scope = "fullSolution",
            },
            ["csharp|inlay_hints"] = {
                csharp_enable_inlay_hints_for_implicit_object_creation = true,
                csharp_enable_inlay_hints_for_implicit_variable_types = true,
                csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                csharp_enable_inlay_hints_for_types = true,
                dotnet_enable_inlay_hints_for_indexer_parameters = true,
                dotnet_enable_inlay_hints_for_literal_parameters = true,
                dotnet_enable_inlay_hints_for_object_creation_parameters = true,
                dotnet_enable_inlay_hints_for_other_parameters = true,
                dotnet_enable_inlay_hints_for_parameters = true,
                dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
                dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
                dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
            },
            ["csharp|symbol_search"] = {
                dotnet_search_reference_assemblies = true,
            },
            ["csharp|completion"] = {
                dotnet_show_completion_items_from_unimported_namespaces = true,
                dotnet_show_name_completion_suggestions = true,
                dotnet_provide_regex_completions = true,
            },
            ["csharp|codelens"] = {
                dotnet_enable_references_code_lens = true,
                dotnet_enable_tests_code_lens = true,
            },
            ["csharp|formatting"] = {
                dotnet_organize_imports_on_format = true,
            },
        },
    },
    init = function()
        vim.keymap.set("n", "<leader>fp", function()
            if not vim.g.roslyn_nvim_selected_solution then
                return vim.notify("No solution file found")
            end

            local projects = require("roslyn.sln.api").projects(vim.g.roslyn_nvim_selected_solution)
            local files = vim.iter(projects)
                :map(function(it)
                    return vim.fs.dirname(it)
                end)
                :totable()

            Snacks.picker.files({ dirs = files })
        end, { desc = "[F]ind in [P]roject files" })

        -- ask for diagnostics every time we leave insert mode
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

        -- remove unnecessary usings
        vim.api.nvim_create_user_command("CSFixUsings", function()
            local bufnr = vim.api.nvim_get_current_buf()

            local clients = vim.lsp.get_clients({ name = "roslyn" })
            if not clients or vim.tbl_isempty(clients) then
                vim.notify("Couldn't find client", vim.log.levels.ERROR, { title = "Roslyn" })
                return
            end

            local client = clients[1]
            local action = {
                kind = "quickfix",
                data = {
                    CustomTags = { "RemoveUnnecessaryImports" },
                    TextDocument = { uri = vim.uri_from_bufnr(bufnr) },
                    CodeActionPath = { "Remove unnecessary usings" },
                    Range = {
                        ["start"] = { line = 0, character = 0 },
                        ["end"] = { line = 0, character = 0 },
                    },
                    UniqueIdentifier = "Remove unnecessary usings",
                },
            }

            client:request("codeAction/resolve", action, function(err, resolved_action)
                if err then
                    vim.notify("Fix using directives failed", vim.log.levels.ERROR, { title = "Roslyn" })
                    return
                end
                vim.lsp.util.apply_workspace_edit(resolved_action.edit, client.offset_encoding)
            end)
        end, { desc = "Remove unnecessary using directives" })

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
    end,
    -- dependencies = {
    --     {
    --         "khoido2003/roslyn-filewatch.nvim",
    --         config = function()
    --             require("roslyn_filewatch").setup({})
    --         end,
    --     },
    -- },
}
