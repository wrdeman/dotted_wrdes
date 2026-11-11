-- Native Neovim 0.11+ LSP configuration.
-- nvim-lspconfig (installed via lazy) registers default cmd/filetypes/root_markers
-- for each server; we customise with vim.lsp.config and activate with vim.lsp.enable.

-- ── Diagnostics ──────────────────────────────────────────────────────────────

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
vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })

-- ── Go ───────────────────────────────────────────────────────────────────────

vim.lsp.config("gopls", {
    settings = {
        gopls = {
            analyses    = { unusedparams = true, shadow = true },
            staticcheck = true,
            gofumpt     = true,
        },
    },
})

-- ── Python / Django ──────────────────────────────────────────────────────────

vim.lsp.config("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode       = "basic",
                autoSearchPaths        = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
})

-- ── Lua (for editing this config) ────────────────────────────────────────────

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime     = { version = "LuaJIT" },
            workspace   = {
                library         = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            diagnostics = { globals = { "vim" } },
            telemetry   = { enable = false },
        },
    },
})

-- ── Python lint/quick-fix (ruff) ─────────────────────────────────────────────
-- Runs alongside pyright: ruff owns linting + code actions, pyright owns
-- type-checking + hover. Disable ruff's hover so pyright's wins.
vim.lsp.config("ruff", {
    on_attach = function(client)
        client.server_capabilities.hoverProvider = false
    end,
})

-- ── SQL (sqls) ───────────────────────────────────────────────────────────────
-- Completion, go-to-definition and hover for SQL. DB connections are NOT set
-- here — interactive querying goes through dadbod-ui (per-project .env, see
-- nvim-sql.md); sqls runs with its defaults for editing assistance.
vim.lsp.config("sqls", {})

-- ── Terraform ────────────────────────────────────────────────────────────────
-- terraform-ls: completion, validation and docs for .tf/.tfvars (nvim-lspconfig's
-- default filetypes/root_markers are already correct — no overrides needed).
-- Mason package name is "terraform-ls" (see init.lua); the terraform CLI binary
-- itself is installed by install.sh, not Mason.
--
-- nvim-lspconfig's bundled on_attach calls vim.lsp.codelens.enable(), added
-- after Neovim 0.11.2 (the version this config targets) — on_attach otherwise
-- throws ON_ATTACH_ERROR on every terraformls buffer. Override on_attach to
-- fall back to the old refresh-on-event pattern when .enable isn't present;
-- this still picks up .enable automatically once nvim is upgraded.
vim.lsp.config("terraformls", {
    on_attach = function(_, bufnr)
        if vim.lsp.codelens.enable then
            vim.lsp.codelens.enable(true, { bufnr = bufnr })
        else
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                buffer = bufnr,
                callback = function() vim.lsp.codelens.refresh({ bufnr = bufnr }) end,
            })
        end
    end,
})

-- <leader>td: open the registry.terraform.io docs page for the resource/data
-- source block the cursor is inside (hover only shows terraform-ls's trimmed
-- schema, not the full registry page).
local function open_terraform_registry_docs()
    local kind, rtype
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    for i = lnum, 1, -1 do
        local line = vim.fn.getline(i)
        kind, rtype = line:match('^%s*(resource)%s*"([%w_]+)"')
        if not kind then
            kind, rtype = line:match('^%s*(data)%s*"([%w_]+)"')
        end
        if kind then break end
    end
    if not kind then
        vim.notify("No resource/data block found above cursor", vim.log.levels.WARN)
        return
    end

    local prefix, name = rtype:match("^([%w]+)_(.+)$")
    if not prefix then
        vim.notify("Could not parse provider prefix from " .. rtype, vim.log.levels.WARN)
        return
    end

    -- Look for an explicit source in required_providers (e.g. prefix = { source = "hashicorp/aws" }).
    local source
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        local src = line:match(prefix .. '%s*=.-source%s*=%s*"([%w%-_/]+)"')
        if src then
            source = src
            break
        end
    end
    source = source or ("hashicorp/" .. prefix)

    local section = (kind == "resource") and "resources" or "data-sources"
    local url = ("https://registry.terraform.io/providers/%s/latest/docs/%s/%s"):format(source, section, name)
    vim.ui.open(url)
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "terraform", "hcl" },
    callback = function(args)
        vim.keymap.set("n", "<leader>td", open_terraform_registry_docs,
            { buffer = args.buf, silent = true, desc = "Open Terraform registry docs" })
    end,
})

-- ── Enable servers ────────────────────────────────────────────────────────────

vim.lsp.enable({ "gopls", "pyright", "lua_ls", "ruff", "sqls", "terraformls" })

-- Note: format + organise-imports on save is handled by conform.nvim
-- (goimports + gofumpt for Go, ruff for Python) — see plugins/conform.lua.
