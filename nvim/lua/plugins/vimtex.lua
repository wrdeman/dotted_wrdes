-- vimtex: LaTeX editing and compilation
-- Requires: a LaTeX distribution (texlive-full recommended) + a PDF viewer

vim.g.vimtex_view_method = "zathura"   -- already in your dotfiles!
vim.g.vimtex_compiler_method = "latexmk"

vim.g.vimtex_compiler_latexmk = {
    build_dir  = "",
    callback   = 1,
    continuous = 1,   -- watch mode: recompile on save
    executable = "latexmk",
    hooks      = {},
    options    = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-pdf",
    },
}

-- Suppress some common benign warnings
vim.g.vimtex_quickfix_ignore_filters = {
    "Underfull",
    "Overfull",
    "specifier changed to",
    "Token not allowed",
}

-- Key mappings:
--   <leader>ll  compile / start watcher
--   <leader>lv  forward search (SyncTeX)
--   <leader>le  open quickfix (errors)
--   <leader>lc  clean auxiliary files
--   <leader>lx  close vimtex
