# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles repo (`dotted_wrdes`). No build, no test suite, no app. The "product" is config files and one bootstrap script (`install.sh`) that installs tools and symlinks these files into `$HOME` / `$HOME/.config`. Cross-platform: macOS (Homebrew) and Debian/Ubuntu Linux (apt + GitHub releases).

## Commands

```sh
./install.sh            # install packages for the detected OS + create symlinks
./install.sh --links    # only (re)create symlinks, skip all package installs
./install.sh --latex    # also install MacTeX (macOS) / prompt TeX Live (Linux)
```

Verify a shell change without committing: `zsh -n .zshrc` (syntax check), then `exec zsh`.
Neovim plugins auto-install on first launch via lazy.nvim; `:Lazy sync` to update, `:Mason` to manage LSP servers.

## Architecture

**`install.sh` is the hub.** It is idempotent and the single source of truth for both *what gets installed* and *what gets linked*. Two facts matter when editing anything here:

- `install_links()` (≈line 294) is the authoritative symlink map. Adding a new dotfile means adding a `symlink "$DOTFILES/x" "$HOME/x"` line — the file existing in the repo does nothing on its own. `symlink()` backs up a pre-existing real file to `*.bak` before linking.
- OS branching is by `uname -s` (`Darwin` vs `Linux`). macOS installs via Homebrew formulae; Linux installs via apt, plus Neovim from GitHub release tarball into `~/.local/bin` and Node via NodeSource. i3/compton/zathura links and the `~/.local/bin` PATH line are **Linux-only** — keep new desktop-environment config inside the `[[ "$OS" == "Linux" ]]` guards.

**Neovim config (`nvim/`) is modular Lua, loaded in order by `init.lua`:** `options` → `keymaps` → `plugins`.
- `lua/plugins/init.lua` bootstraps lazy.nvim and is the plugin manifest. Each plugin's `config = function() require("plugins.X") end` points to its own file in `lua/plugins/`. Add a plugin = add a spec here (+ its config file if non-trivial).
- LSP stack: Mason installs servers; `lua/plugins/lsp.lua` configures them via the new `vim.lsp.config()` / `vim.lsp.enable()` API (not the old `lspconfig.X.setup{}`). Servers wired up: `gopls`, `pyright`, `lua_ls` — the `ensure_installed` list in `init.lua` and the configs in `lsp.lua` must stay in sync. Buffer-local LSP keymaps are set in an `LspAttach` autocmd; Go files format + organise imports on `BufWritePre`.
- Leader is `<Space>`. Completion is nvim-cmp; fuzzy-finding is Telescope (needs `ripgrep` for live_grep — that's why install.sh pulls it in).

**Shell:** `.zshrc` is oh-my-zsh based and sources `.aliases` (kept separate so aliases/functions live in one place). `lazy-lock.json` pins plugin commits — commit it when intentionally updating plugins.

## Conventions

- Match the existing install.sh style: `info`/`ok`/`warn`/`die` helpers for output, `has cmd` for presence checks, guard every step so re-running is safe.
- Keep changes cross-platform. If something is macOS- or Linux-only, gate it on `$OS` rather than assuming one platform.
- `Readme.md` is a manual package/font checklist that predates `install.sh`; `install.sh` is the maintained path.
- `nvim-tmux.md` documents the Neovim and tmux configs (keymaps, plugins, LSP, options). **Keep it in sync:** whenever you change `.tmux.conf` or anything under `nvim/` (a keymap, plugin, LSP server, option, or vimtex/telescope binding), update `nvim-tmux.md` in the same change.
