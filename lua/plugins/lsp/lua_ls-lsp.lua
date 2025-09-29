return {
    -- cmd = { ... },
    -- filetypes = { ... },
    -- capabilities = {},
    settings = {
        Lua = {
            completion = {
                callSnippet = "Replace",
                displayContext = 5,
                enable = true,
                keywordSnippet = "Replace",
                showParams = true,
                showWords = "Enable",
            },
            codeLens = {
                enable = true,
            },
            hint = {
                arrayIndex = "Enable",
                enable = true,
                setType = true,
            },
            language = {
                completeAnnotation = true,
                fixIndent = true,
            },
            signatureHelp = {
                enable = true,
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
        },
    },
}
