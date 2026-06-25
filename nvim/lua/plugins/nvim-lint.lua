local lint = require("lint")

-- conform.nvim owns formatting; nvim-lint owns lint diagnostics (the role ruff
-- fills for Python via its LSP). sqlfluff is the same binary used by the conform
-- formatter — installed by mason-tool-installer (see plugins/init.lua).
lint.linters_by_ft = {
    sql = { "sqlfluff" },
}

-- sqlfluff lints with no dialect by default; pin postgres to match the conform
-- formatter. A project-level .sqlfluff file still overrides the dialect/rules.
lint.linters.sqlfluff.args = { "lint", "--format=json", "--dialect=postgres", "-" }

-- Lint the buffer on read, save and leaving insert mode.
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
    callback = function()
        lint.try_lint()
    end,
})
