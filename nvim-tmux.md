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
│       ├── lsp.lua       LSP servers + diagnostics
│       ├── conform.lua   formatters + format-on-save
│       ├── dap.lua       debugging (DAP) adapters + keymaps
│       ├── flutter.lua   flutter-tools (dartls + fvm, hot reload, DAP)
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
| `:MasonToolsUpdate` | update the mason-tool-installer tool list (gofumpt, goimports, stylua, delve, debugpy) |
| `:ConformInfo` | show conform formatters + their status for the buffer |
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
- **pyright** — basic type-checking + hover
- **ruff** — Python linting + code actions (hover disabled so pyright's wins)
- **lua_ls** — configured for editing this config (`vim` global, LuaJIT)
- **dartls** — set up by **flutter-tools.nvim** (see Flutter below), *not* Mason; comes from the Flutter SDK. Still fires the same `LspAttach` keymaps below.

Configured via the new `vim.lsp.config()` / `vim.lsp.enable()` API (not legacy
`lspconfig.X.setup{}`). Diagnostics show as virtual text + signs, severity-sorted.
**Formatting / organise-imports on save is owned by conform.nvim** (see below), not the
LSP — `lsp.lua` no longer formats.

LSP keymaps (buffer-local, set on `LspAttach`):

| Key | Action |
|-----|--------|
| `gd` / `gD` | definition / declaration |
| `gi` / `gt` | implementation / type definition |
| `gr` | references |
| `K` | hover docs |
| `<leader>rn` | rename symbol |
| `<leader>ca` | code action |
| `[d` / `]d` | previous / next diagnostic |
| `<leader>d` | show diagnostic float |

(`<leader>f` formats — owned by conform.nvim, see Formatting below.)

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

Needs `ripgrep` (pulled in by `install.sh`) for live grep. Uses **telescope-fzf-native**
(compiled with `make` on install) for fast fuzzy matching.

| Key | Action |
|-----|--------|
| `<leader>ff` | find files |
| `<leader>fg` | live grep |
| `<leader>fb` | buffers |
| `<leader>fh` | help tags |
| `<leader>fd` | diagnostics |

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

### Formatting — conform.nvim (`conform.lua`)

Owns `<leader>f` (normal + visual) and **format-on-save**. Per-filetype formatters
(binaries installed by **mason-tool-installer**):

| Filetype | Formatters |
|----------|------------|
| python | `ruff_organize_imports` → `ruff_format` (replaces black + isort) |
| go | `goimports` → `gofumpt` |
| lua | `stylua` |

Other filetypes fall back to the LSP formatter (`lsp_format = "fallback"`).

### Debugging — DAP (`dap.lua`)

`nvim-dap` + `nvim-dap-ui` (auto-opens on session start, closes on exit). Adapters:
**dap-go** (delve) and **dap-python** (debugpy, from Mason's install path). Both binaries
come from mason-tool-installer.

| Key | Action |
|-----|--------|
| `<leader>db` | toggle breakpoint |
| `<leader>dB` | conditional breakpoint (prompts) |
| `<leader>dc` | continue / start |
| `<leader>di` / `<leader>do` / `<leader>dO` | step into / over / out |
| `<leader>dr` | toggle REPL |
| `<leader>dl` | run last |
| `<leader>du` | toggle DAP UI |
| `<leader>dt` | terminate |

> Note: `<leader>d` (diagnostic float) is also a prefix for the `<leader>d*` debug maps, so
> bare `<leader>d` waits `timeoutlen` (300 ms) before firing.

### Trouble (`folke/trouble.nvim`)

Diagnostics / references / symbols in a dedicated panel.

| Key | Action |
|-----|--------|
| `<leader>xx` | diagnostics (workspace) |
| `<leader>xX` | diagnostics (current buffer) |
| `<leader>xs` | symbols outline |
| `<leader>xl` / `<leader>xq` | location list / quickfix |
| `gR` | LSP references |

### Flutter / Dart — flutter-tools.nvim (`flutter.lua`)

Loads on `dart` files. Sets up **dartls** (with nvim-cmp capabilities; LSP keymaps come from
the shared `LspAttach` autocmd in `lsp.lua`), wires the **DAP** debugger (`<leader>d*` maps),
and drives the run cycle. **`fvm = true`** — uses the project's `.fvm/flutter_sdk`, matching
the fvm shell workflow (so the project must be fvm-pinned: `fvm use <version>`).

Run-cycle keymaps (`<leader>fl*`) — **buffer-local to dart files** (set by a `FileType dart`
autocmd, not a global `keys` trigger, so they only exist where the `:Flutter*` commands do —
otherwise firing one from a non-dart buffer gives `E492`):

| Key | Action |
|-----|--------|
| `<leader>flr` | run |
| `<leader>flR` | hot restart |
| `<leader>flh` | hot reload |
| `<leader>flq` | quit |
| `<leader>fld` | devices |
| `<leader>fle` | emulators |
| `<leader>flo` | outline toggle |
| `<leader>flD` | DevTools |
| `<leader>fll` | LSP restart |

> Like `<leader>f` (conform format) vs `<leader>ff` (telescope), bare `<leader>f` waits
> `timeoutlen` before firing because `<leader>fl*` shares the prefix.

### which-key

Pops up the available `<leader>` bindings after a short delay — no config beyond defaults.

### Other plugins

- **vim-tmux-navigator** — `<C-h/j/k/l>` move seamlessly across nvim splits and tmux panes
- **gruvbox** colorscheme (hard contrast)
- **lualine** statusline (gruvbox theme, single global statusline, branch/diff/diagnostics)
- **gitsigns** — git signs in the gutter
- **lazygit.nvim** — `<leader>gg` opens the lazygit TUI in a float (needs the `lazygit` binary, pulled in by `install.sh`)
- **nvim-autopairs** — auto-close brackets/quotes
- **Comment.nvim** — `gcc` to toggle a line, `gc` in visual mode
