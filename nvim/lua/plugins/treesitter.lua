-- markdown + markdown_inline are pulled in for octo.nvim: octo buffers register
-- `markdown` as their parser language (see plugins/octo.lua) so PR/issue bodies
-- and review comments are highlighted as GitHub-flavoured markdown.
-- "terraform" also backs .tfvars (filetype terraform-vars — nvim-treesitter's
-- built-in filetype map already points it at this same parser); "hcl" backs
-- generic .hcl files (Packer/Nomad/Consul). Both filetypes are detected by
-- Neovim core out of the box — no vim.filetype.add/register call needed here.
require("nvim-treesitter").setup({
    ensure_installed = { "go", "python", "lua", "bash", "latex", "vim", "vimdoc", "json", "yaml", "toml", "hurl", "sql", "terraform", "hcl", "markdown", "markdown_inline" },
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
