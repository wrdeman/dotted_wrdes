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
        map("<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
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

vim.lsp.enable({ "gopls", "pyright", "lua_ls" })

-- Format + organise imports on save for Go files
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        local clients = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })
        if #clients == 0 then return end
        local enc = clients[1].offset_encoding
        local params = vim.lsp.util.make_range_params(0, enc)
        params.context = { only = { "source.organizeImports" }, diagnostics = {} }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
            end
        end
        vim.lsp.buf.format({ async = false })
    end,
})
