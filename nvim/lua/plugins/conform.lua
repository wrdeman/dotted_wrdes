local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        -- ruff replaces black + isort: organise imports, then format
        python = { "ruff_organize_imports", "ruff_format" },
        go     = { "goimports", "gofumpt" },
        lua    = { "stylua" },
        sql    = { "sqlfluff" },
        -- terraform_fmt is conform's built-in formatter: shells out to
        -- `terraform fmt -no-color -` (needs the `terraform` CLI — install.sh).
        -- terraform-vars is .tfvars' filetype; it needs its own entry here
        -- since formatters_by_ft doesn't inherit from "terraform".
        terraform          = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
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
    format_on_save = function(bufnr)
        -- octo buffers are not files: octo intercepts `:w` with its own
        -- BufWriteCmd on octo://* to push the PR/issue body or comment to
        -- GitHub. conform's BufWritePre hook runs first, so formatting (or the
        -- LSP fallback) would rewrite the comment text out from under it.
        if vim.bo[bufnr].filetype == "octo" then
            return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
})

-- <leader>f (normal + visual) is declared in plugins/init.lua's lazy `keys` so it
-- loads conform on demand; format_on_save above handles the automatic path.
