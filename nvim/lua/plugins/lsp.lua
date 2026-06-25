local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Diagnostic display settings
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = true },
})

-- Keymaps that only make sense when an LSP attaches to the buffer
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, silent = true, desc = desc })
        end
        map("gd",         vim.lsp.buf.definition,      "Go to definition")
        map("gD",         vim.lsp.buf.declaration,     "Go to declaration")
        map("gi",         vim.lsp.buf.implementation,  "Go to implementation")
        map("gt",         vim.lsp.buf.type_definition, "Go to type definition")
        map("gr",         vim.lsp.buf.references,      "References")
        map("K",          vim.lsp.buf.hover,            "Hover docs")
        map("<leader>rn", vim.lsp.buf.rename,           "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action,      "Code action")
        -- <leader>f (format) is owned by conform.nvim — see plugins/conform.lua
        map("[d",         function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
        map("]d",         function() vim.diagnostic.jump({ count = 1, float = true }) end,  "Next diagnostic")
        map("<leader>d",  vim.diagnostic.open_float,    "Show diagnostic")
    end,
})

-- Apply completion capabilities to every server (merges with nvim-lspconfig's
-- shipped lsp/<name>.lua defaults: cmd, filetypes, root_markers).
vim.lsp.config("*", { capabilities = capabilities })

-- ── Go ──────────────────────────────────────────────────────────────────────
vim.lsp.config("gopls", {
    settings = {
        gopls = {
            analyses  = { unusedparams = true, shadow = true },
            staticcheck = true,
            gofumpt   = true,   -- stricter gofmt formatting
        },
    },
})

-- ── Python / Django ──────────────────────────────────────────────────────────
vim.lsp.config("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",  -- "strict" when you want more noise
                autoSearchPaths  = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
})

-- ── Lua (for editing this config) ───────────────────────────────────────────
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime  = { version = "LuaJIT" },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            diagnostics = { globals = { "vim" } },
            telemetry   = { enable = false },
        },
    },
})

-- ── Python lint/quick-fix (ruff) ──────────────────────────────────────────────
-- Runs alongside pyright: ruff owns linting + code actions, pyright owns
-- type-checking + hover. Disable ruff's hover so pyright's wins.
vim.lsp.config("ruff", {
    on_attach = function(client)
        client.server_capabilities.hoverProvider = false
    end,
})

-- ── SQL (sqls) ────────────────────────────────────────────────────────────────
-- Completion, go-to-definition and hover for SQL. DB connections are NOT set
-- here — interactive querying goes through dadbod-ui (per-project .env, see
-- nvim-sql.md); sqls runs with its defaults for editing assistance.
vim.lsp.config("sqls", {})

vim.lsp.enable({ "gopls", "pyright", "lua_ls", "ruff", "sqls" })

-- Note: format + organise-imports on save is handled by conform.nvim
-- (goimports + gofumpt for Go, ruff for Python) — see plugins/conform.lua.
