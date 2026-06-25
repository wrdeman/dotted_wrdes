local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        -- ruff replaces black + isort: organise imports, then format
        python = { "ruff_organize_imports", "ruff_format" },
        go     = { "goimports", "gofumpt" },
        lua    = { "stylua" },
        sql    = { "sqlfluff" },
    },

    formatters = {
        -- sqlfluff needs an explicit dialect; default to postgres. A project
        -- .sqlfluff file still overrides this for project-specific rules.
        sqlfluff = {
            args = { "format", "--dialect=postgres", "-" },
        },
    },

    -- Format on save; fall back to the LSP formatter for filetypes with no
    -- formatter configured above (so e.g. LSP-only languages still format).
    format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
    },
})

-- <leader>f (normal + visual) is declared in plugins/init.lua's lazy `keys` so it
-- loads conform on demand; format_on_save above handles the automatic path.
