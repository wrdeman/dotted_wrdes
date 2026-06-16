# Neovim & tmux config

Reference for the Neovim (`nvim/`) and tmux (`.tmux.conf`) setup in this repo. Both are
symlinked into place by `install.sh` (`~/.config/nvim` and `~/.tmux.conf`).

> Keep this file in sync when you change `.tmux.conf` or anything under `nvim/`.

---

## tmux (`.tmux.conf`)

Default shell is `/bin/zsh`. `tmux-256color` + truecolor, 50 000-line scrollback, vi-style
copy mode.

### Prefix

**Prefix is `C-z`** (not the default `C-b`). `C-z C-z` jumps to the last window.

| Key | Action |
|-----|--------|
| `C-z` | prefix |
| `C-z C-z` | last window |
| `C-z r` | reload `~/.tmux.conf` |
| `C-z Space` | next window |

### Pane navigation (vim-aware)

`C-h/j/k/l` move between panes **without the prefix**. The `is_vim` guard forwards the keys
into Vim/Neovim when a vim-like process owns the pane, so the same keys move splits inside
nvim and panes outside it. This is the tmux half of **vim-tmux-navigator** — nvim's half
(the plugin) moves nvim splits first, then crosses into the adjacent tmux pane at a split
edge. `C-\` jumps to the last pane. Plain `<C-w>` maps would stop dead at the nvim edge
instead of forwarding to tmux — don't use them here.

| Key | Action |
|-----|--------|
| `C-h` / `C-j` / `C-k` / `C-l` | select pane left / down / up / right |
| `C-\` | last pane |

### Windows & layouts

| Key | Action |
|-----|--------|
| `M-Left` / `M-Right` | previous / next window (no prefix) |
| `C-z +` | zoom current pane into a dedicated window |
| `C-z -` | un-zoom (restore pane, kill zoom window) |
| `C-z M-1`..`M-5` | layout: even-horizontal, even-vertical, main-horizontal, main-vertical, tiled |

### Claude Code compatibility

The block at the top enables `allow-passthrough` (desktop notifications + progress bar),
`extended-keys` (Shift+Enter ≠ Enter), and `RGB`/`extkeys` terminal features.
**Do not** re-enable the commented `smcup@:rmcup@` override — it disables the alternate
screen and breaks Claude Code fullscreen rendering and nvim's alt-screen.

---

## Neovim (`nvim/`)

Modular Lua. `init.lua` loads, in order: `options` → `keymaps` → `plugins`.

```
nvim/
├── init.lua              entry point
├── lua/
│   ├── options.lua       vim.opt settings + filetype autocmds
│   ├── keymaps.lua       global keymaps (leader = Space)
│   └── plugins/
│       ├── init.lua      lazy.nvim bootstrap + plugin manifest
│       ├── lsp.lua       LSP servers, diagnostics, format-on-save
│       ├── cmp.lua       nvim-cmp completion
│       ├── treesitter.lua
│       ├── nvim-tree.lua file explorer
│       ├── lualine.lua   statusline
│       └── vimtex.lua    LaTeX
└── lazy-lock.json        pinned plugin commits (commit when updating)
```

**Leader is `<Space>`.** Plugins auto-install on first launch via lazy.nvim.

> **Icons need a Nerd Font.** nvim-tree and lualine use `nvim-web-devicons` glyphs from a
> Nerd Font's private-use range. `install.sh` installs **Hack Nerd Font** (Homebrew cask on
> macOS, GitHub release on Linux) — you must then set your **terminal's font** to it, or the
> icons render as `??`.

### Maintenance commands

| Command | Action |
|---------|--------|
| `:Lazy sync` | install/update/clean plugins |
| `:Lazy` | plugin manager UI |
| `:Mason` | install/manage LSP servers, formatters, linters |
| `:TSUpdate` | update treesitter parsers |
| `:checkhealth` | diagnose problems |

### Options highlights (`options.lua`)

Relative + absolute line numbers, `cursorline`, `signcolumn=yes`, colorcolumn at 100,
`scrolloff=8`, truecolor. 4-space expandtab default. Case-insensitive search with smartcase,
no hlsearch. Splits open right/below. No swap/backup; **persistent undo** under
`stdpath('data')/undo`. System clipboard (`unnamedplus`), mouse enabled.

Filetype overrides: **Go** uses real tabs; **LaTeX** wraps prose (linebreak, no colorcolumn).

### Global keymaps (`keymaps.lua`)

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | move between splits / tmux panes (vim-tmux-navigator) |
| `<C-\>` | jump to last split / tmux pane |
| `<leader>e` / `<F2>` | toggle file tree |
| `<leader>E` | reveal current file in tree |
| `<leader>bd` | delete buffer |
| `[b` / `]b` | previous / next buffer |
| `<leader>w` / `<leader>q` | save / quit |
| `J` / `K` (visual) | move selection down / up |
| `<C-d>` / `<C-u>` | scroll half-page, cursor centred |
| `n` / `N` | next/prev search result, centred |

### LSP (`lsp.lua`)

Servers (installed by Mason, must stay in sync with `ensure_installed` in `plugins/init.lua`):

- **gopls** — analyses (unusedparams, shadow), staticcheck, gofumpt
- **pyright** — basic type-checking
- **lua_ls** — configured for editing this config (`vim` global, LuaJIT)

Configured via the new `vim.lsp.config()` / `vim.lsp.enable()` API (not legacy
`lspconfig.X.setup{}`). Go files **format + organise imports on save** (`BufWritePre`).
Diagnostics show as virtual text + signs, severity-sorted.

LSP keymaps (buffer-local, set on `LspAttach`):

| Key | Action |
|-----|--------|
| `gd` / `gD` | definition / declaration |
| `gi` / `gt` | implementation / type definition |
| `gr` | references |
| `K` | hover docs |
| `<leader>rn` | rename symbol |
| `<leader>ca` | code action |
| `<leader>f` | format buffer |
| `[d` / `]d` | previous / next diagnostic |
| `<leader>d` | show diagnostic float |

### Completion — nvim-cmp (`cmp.lua`)

Sources: LSP, LuaSnip (friendly-snippets), buffer (≥3 chars), path. Bordered windows, ghost
text. Menu labels the source (`[LSP]`, `[Snip]`, `[Buf]`, `[Path]`).

| Key | Action |
|-----|--------|
| `<Tab>` / `<S-Tab>` | next / prev item (or jump snippet) |
| `<CR>` | confirm (no auto-select) |
| `<C-Space>` | trigger completion |
| `<C-e>` | abort |

### Treesitter (`treesitter.lua`)

Parsers: go, python, lua, bash, latex, vim, vimdoc, json, yaml, toml (`auto_install` on).
Highlight + indent enabled. LaTeX highlighting handled by vimtex, not treesitter.
Incremental selection: `<C-space>` grow, `<M-space>` shrink, `<C-s>` scope.

### Telescope (fuzzy finder)

Needs `ripgrep` (pulled in by `install.sh`) for live grep.

| Key | Action |
|-----|--------|
| `<leader>ff` | find files |
| `<leader>fg` | live grep |
| `<leader>fb` | buffers |

### nvim-tree (file explorer)

35-col left panel, shows hidden files (hides `.git`, `node_modules`, `__pycache__`,
`.mypy_cache`), git status glyphs. Toggle with `<leader>e`, reveal current file `<leader>E`.

### vimtex (LaTeX)

Loads only for `tex`/`latex`. Compiler `latexmk` in continuous/watch mode, viewer `zathura`.

| Key | Action |
|-----|--------|
| `<leader>ll` | compile / start watcher |
| `<leader>lv` | forward search (SyncTeX) |
| `<leader>le` | open quickfix (errors) |
| `<leader>lc` | clean auxiliary files |
| `<leader>lx` | close vimtex |

### Other plugins

- **vim-tmux-navigator** — `<C-h/j/k/l>` move seamlessly across nvim splits and tmux panes
- **gruvbox** colorscheme (hard contrast)
- **lualine** statusline (gruvbox theme, single global statusline, branch/diff/diagnostics)
- **gitsigns** — git signs in the gutter
- **nvim-autopairs** — auto-close brackets/quotes
- **Comment.nvim** — `gcc` to toggle a line, `gc` in visual mode
