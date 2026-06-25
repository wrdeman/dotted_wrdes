require("nvim-treesitter.configs").setup({
    ensure_installed = { "go", "python", "lua", "bash", "latex", "vim", "vimdoc", "json", "yaml", "toml", "hurl", "sql" },
    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
        -- vimtex handles LaTeX highlighting; disable treesitter for it to avoid conflicts
        disable = { "latex" },
        additional_vim_regex_highlighting = { "latex" },
    },

    indent = { enable = true },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection    = "<C-space>",
            node_incremental  = "<C-space>",
            scope_incremental = "<C-s>",
            node_decremental  = "<M-space>",
        },
    },
})
