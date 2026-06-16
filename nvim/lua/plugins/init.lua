-- Bootstrap lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Colour scheme (gruvbox is a solid neutral default; swap freely)
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            require("gruvbox").setup({ contrast = "hard" })
            vim.cmd.colorscheme("gruvbox")
        end,
    },

    -- LSP + formatters/linters installer
    { "williamboman/mason.nvim", config = true },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "gopls", "pyright", "lua_ls" },
            automatic_installation = true,
        },
    },

    -- LSP core
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function() require("plugins.lsp") end,
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        config = function() require("plugins.cmp") end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        config = function() require("plugins.treesitter") end,
    },

    -- LaTeX
    {
        "lervag/vimtex",
        ft = { "tex", "latex" },
        config = function() require("plugins.vimtex") end,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function() require("plugins.lualine") end,
    },

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function() require("plugins.nvim-tree") end,
    },

    -- Fuzzy finder (bonus — very useful alongside the above)
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
        },
    },

    -- Seamless split/pane navigation with tmux (pairs with the is_vim
    -- forwarding block in .tmux.conf). Moves nvim splits, then crosses
    -- into tmux panes at the edge.
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp",
            "TmuxNavigateRight", "TmuxNavigatePrevious",
        },
        keys = {
            { "<C-h>",  "<cmd>TmuxNavigateLeft<cr>",     desc = "Nav split/pane left" },
            { "<C-j>",  "<cmd>TmuxNavigateDown<cr>",     desc = "Nav split/pane down" },
            { "<C-k>",  "<cmd>TmuxNavigateUp<cr>",       desc = "Nav split/pane up" },
            { "<C-l>",  "<cmd>TmuxNavigateRight<cr>",    desc = "Nav split/pane right" },
            { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Nav last split/pane" },
        },
    },

    -- Git signs in the gutter
    { "lewis6991/gitsigns.nvim", config = true },

    -- Auto-close brackets/quotes
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

    -- Comment toggle (gcc / gc in visual)
    { "numToStr/Comment.nvim", config = true },
}, {
    ui = { border = "rounded" },
    checker = { enabled = false },
    rocks = { enabled = false },   -- disable luarocks (not needed for this setup)
})
