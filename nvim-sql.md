# PostgreSQL / SQL in Neovim

How database support works in this config: a [vim-dadbod](https://github.com/tpope/vim-dadbod)
+ [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) client, SQL completion,
the `sqls` LSP, and `sqlfluff` formatting. Config lives in `nvim/lua/plugins/dadbod.lua`
(plus the cmp/lsp/conform/treesitter wiring).

> **Connections live in the project, not the dotfiles.** No connection string or
> credential is ever stored in this repo. Each project defines its own connections in a
> **gitignored `.env`**.

---

## Where connections come from

dadbod-ui reads connections from a per-project `.env` file via
[vim-dotenv](https://github.com/tpope/vim-dotenv). It is wired up with:

```lua
vim.g.db_ui_dotenv_variable_prefix = "DB_UI_"   -- nvim/lua/plugins/dadbod.lua
```

`g:dbs` is **not** set and no connection is hardcoded anywhere in the config — the `.env`
is the only source.

### `.env` format

One line per connection, `DB_UI_<name>=<connection_url>`:

```sh
DB_UI_dev=postgresql://user:pass@localhost:5432/mydb
DB_UI_staging=postgresql://user:pass@staging-host:5432/mydb
```

- The connection **name in the DBUI sidebar is the part after the `DB_UI_` prefix**,
  **lowercased**. So `DB_UI_dev` → `dev`, and `DB_UI_STAGING` → `staging`.
- The value is any [dadbod-supported URL](https://github.com/tpope/vim-dadbod#connection-strings)
  — `postgresql://…` for Postgres, also `mysql://`, `sqlite:…`, etc.

### Gitignore the `.env` — required

Credentials must never be committed. Add this to the **project's** `.gitignore`
(not this dotfiles repo):

```gitignore
.env
```

---

## How it works

1. `cd` into the project root (the dir holding `.env`) and open `nvim` there — CWD must be
   the project root.
2. Toggle the drawer with **`<leader>Du`** (or `:DBUIToggle`).
3. On open, an autocmd reads `./.env` via vim-dotenv and refreshes the drawer, so every
   `DB_UI_*` connection appears automatically — no manual `:Dotenv` needed.
4. Expand a connection to browse schemas/tables, or open a scratch query buffer and write
   SQL against it.

If the connections don't show up, check that you launched nvim from the project root
(`:pwd`) and that `.env` uses the `DB_UI_` prefix.

---

## Keymaps

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Du` | n | Toggle the DBUI drawer (`:DBUIToggle`) |
| `<leader>Df` | n | Find/jump to a DBUI query buffer (`:DBUIFindBuffer`) |
| `<leader>S` | n, v | Execute the query (whole buffer, or the visual selection) |

`<leader>S` is buffer-local to `sql`/`plsql` buffers (it maps dadbod-ui's
`<Plug>(DBUI_ExecuteQuery)`, which only exists there).

---

## Editing assistance

- **Completion** (nvim-cmp): in `sql`/`plsql` buffers the `[DB]` source
  (vim-dadbod-completion) completes tables/columns/keywords from the live connection,
  alongside the `sqls` LSP. Configured in `nvim/lua/plugins/cmp.lua`.
- **LSP**: `sqls` — installed by Mason (`ensure_installed` in `plugins/init.lua`), configured
  in `plugins/lsp.lua`. Gives completion, go-to-definition and hover. Fires the same
  `LspAttach` keymaps as every other server (`gd`, `K`, `<leader>rn`, …).
- **Formatting**: `sqlfluff` with the **postgres** dialect, run by conform.nvim on
  `<leader>f` and on save (`plugins/conform.lua`). The binary is installed by
  mason-tool-installer. A project-level `.sqlfluff` file overrides the dialect/rules.
- **Linting**: `sqlfluff lint` (postgres dialect) via nvim-lint (`plugins/nvim-lint.lua`),
  surfaced as inline diagnostics on read / save / leaving insert mode. Same binary as the
  formatter; a project `.sqlfluff` overrides the rules.
- **Treesitter**: the `sql` parser is in `ensure_installed` for highlighting/indent.
