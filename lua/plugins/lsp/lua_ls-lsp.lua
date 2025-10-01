return {
    -- cmd = { ... },
    filetypes = {
        "lua",
    },
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
                enable = true,
            },
            language = {
                completeAnnotation = true,
                fixIndent = true,
            },
            signatureHelp = {
                enable = true,
            },
        },
    },
}
