-- vim-dadbod-ui configuration.
--
-- Connections are NEVER defined here. They live in a per-project, gitignored
-- .env read by vim-dotenv: each `DB_UI_<name>=<url>` line becomes a connection
-- named <name> (everything after the prefix, lowercased) in the DBUI sidebar.
-- See nvim-sql.md for the .env format and workflow.
--
-- These globals are read when dadbod-ui loads, so they must be set at startup —
-- the plugin spec calls this module from `init` (before the lazy cmd/ft
-- triggers fire), not from `config` (which runs after load).

-- Read connections from the project's .env via vim-dotenv (DB_UI_* variables).
-- NOTE: g:dbs is intentionally NOT set — no connection is hardcoded.
vim.g.db_ui_dotenv_variable_prefix = "DB_UI_"

-- Nerd-font icons in the drawer (we already pull in nvim-web-devicons).
vim.g.db_ui_use_nerd_fonts = 1

-- Don't auto-run the query on save; run it explicitly via <leader>S.
vim.g.db_ui_execute_on_save = 0

-- Load the project's .env when the drawer opens so DB_UI_* connections appear
-- without a manual :Dotenv. dadbod-ui merges environ() with vim-dotenv's
-- DotenvGet(); reading .env into the drawer buffer here (then `R` to refresh)
-- populates that for the nameless drawer buffer. CWD must be the project root.
vim.api.nvim_create_autocmd("User", {
    pattern = "DBUIOpened",
    callback = function()
        if vim.fn.exists("*DotenvRead") == 1 then
            vim.b.dotenv = vim.fn.DotenvRead(".env")
            vim.cmd("normal R") -- no bang: use dadbod-ui's buffer-local refresh map
        end
    end,
})

-- Run-query keymap, buffer-local to SQL buffers (mirrors dadbod-ui's default
-- <Plug>; set per-buffer like the flutter maps so it only binds where the plug
-- exists). <leader>Du / <leader>Df (toggle / find buffer) live in the lazy
-- `keys` spec in plugins/init.lua.
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sql", "mysql", "plsql" },
    callback = function(ev)
        vim.keymap.set({ "n", "v" }, "<leader>S", "<Plug>(DBUI_ExecuteQuery)", {
            buffer = ev.buf,
            silent = true,
            desc = "DB execute query",
        })
    end,
})
