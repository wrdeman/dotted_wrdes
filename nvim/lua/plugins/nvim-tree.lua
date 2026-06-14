-- Disable netrw in favour of nvim-tree
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
        width = 35,
        side  = "left",
    },
    renderer = {
        group_empty = true,
        icons = {
            glyphs = {
                default = "",
                symlink = "",
                git     = { unstaged = "✗", staged = "✓", untracked = "★" },
            },
        },
    },
    filters = {
        dotfiles = false,   -- show hidden files by default
        custom   = { ".git", "node_modules", "__pycache__", ".mypy_cache" },
    },
    git = { enable = true, ignore = false },
    actions = {
        open_file = {
            quit_on_open = false,
            window_picker = { enable = true },
        },
    },
})
