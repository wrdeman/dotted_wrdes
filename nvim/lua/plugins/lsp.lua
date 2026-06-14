local lspconfig = require("lspconfig")
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

-- Shared on_attach: keymaps that only make sense when an LSP is active
local on_attach = function(_, bufnr)
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
    map("<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
    map("[d",         vim.diagnostic.goto_prev,     "Prev diagnostic")
    map("]d",         vim.diagnostic.goto_next,     "Next diagnostic")
    map("<leader>d",  vim.diagnostic.open_float,    "Show diagnostic")
end

-- ── Go ──────────────────────────────────────────────────────────────────────
lspconfig.gopls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        gopls = {
            analyses  = { unusedparams = true, shadow = true },
            staticcheck = true,
            gofumpt   = true,   -- stricter gofmt formatting
        },
    },
})

-- Format + organise imports on save for Go files
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
                end
            end
        end
        vim.lsp.buf.format({ async = false })
    end,
})

-- ── Python / Django ──────────────────────────────────────────────────────────
lspconfig.pyright.setup({
    capabilities = capabilities,
    on_attach = on_attach,
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
lspconfig.lua_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
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
