local lint = require("lint")

-- conform.nvim owns formatting; nvim-lint owns lint diagnostics (the role ruff
-- fills for Python via its LSP). sqlfluff is the same binary used by the conform
-- formatter — installed by mason-tool-installer (see plugins/init.lua).
-- tflint is nvim-lint's built-in linter (cmd `tflint --format=json --recursive`,
-- reads from disk not stdin); defaults are fine as-is, unlike sqlfluff which
-- needed an explicit dialect. terraform-vars (.tfvars) needs its own entry
-- since linters_by_ft doesn't inherit from "terraform".
lint.linters_by_ft = {
    sql = { "sqlfluff" },
    terraform = { "tflint" },
    ["terraform-vars"] = { "tflint" },
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
