local lint = require("lint")

-- conform.nvim owns formatting; nvim-lint owns lint diagnostics (the role ruff
-- fills for Python via its LSP). sqlfluff is the same binary used by the conform
-- formatter — installed by mason-tool-installer (see plugins/init.lua).
-- tflint is nvim-lint's built-in linter (cmd `tflint --format=json --recursive`,
-- reads from disk not stdin); defaults are fine as-is, unlike sqlfluff which
-- needed an explicit dialect. terraform-vars (.tfvars) needs its own entry
-- since linters_by_ft doesn't inherit from "terraform".
-- checkov is terraform-only (IaC security/misconfig scanning); .tfvars has no
-- resources to scan so it's left off that entry. Not a Mason package — binary
-- comes from install.sh (brew on macOS, `uv tool install` on Linux).
lint.linters_by_ft = {
    sql = { "sqlfluff" },
    terraform = { "tflint", "checkov" },
    ["terraform-vars"] = { "tflint" },
}

-- sqlfluff lints with no dialect by default; pin postgres to match the conform
-- formatter. A project-level .sqlfluff file still overrides the dialect/rules.
lint.linters.sqlfluff.args = { "lint", "--format=json", "--dialect=postgres", "-" }

-- checkov has no nvim-lint built-in, so it's defined here. Scans the current
-- file only (`-f`, not `-d --recursive` like tflint) — faster, and checkov's
-- checks are per-resource so cross-file graph analysis isn't needed for this
-- use case. Severity is reported null by the free/OSS tier, so every finding
-- maps to WARN rather than ERROR (checkov flags misconfigurations, not syntax
-- errors — nothing here should block editing).
lint.linters.checkov = {
    cmd = "checkov",
    stdin = false,
    append_fname = false,
    ignore_exitcode = true,
    args = {
        "-f",
        function() return vim.api.nvim_buf_get_name(0) end,
        "-o", "json",
        "--compact",
        "--quiet",
    },
    parser = function(output)
        if output == "" then return {} end
        local ok, decoded = pcall(vim.json.decode, output)
        if not ok or not decoded.results then return {} end

        local diagnostics = {}
        for _, check in ipairs(decoded.results.failed_checks or {}) do
            local range = check.file_line_range or { 1, 1 }
            table.insert(diagnostics, {
                lnum = range[1] - 1,
                end_lnum = range[2] - 1,
                col = 0,
                end_col = 0,
                severity = vim.diagnostic.severity.WARN,
                source = "checkov",
                code = check.check_id,
                message = string.format("%s: %s", check.check_id, check.check_name),
            })
        end
        return diagnostics
    end,
}

-- Lint the buffer on read, save and leaving insert mode.
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
    callback = function()
        lint.try_lint()
    end,
})
