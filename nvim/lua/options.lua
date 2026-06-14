-- Disable unused providers (suppresses checkhealth warnings for Perl/Ruby/Node)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

local o = vim.opt

-- Appearance
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.scrolloff = 8
o.colorcolumn = "100"

-- Indentation (overridden per-filetype by treesitter/LSP)
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true

-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = false
o.incsearch = true

-- Splits
o.splitright = true
o.splitbelow = true

-- Files
o.swapfile = false
o.backup = false
o.undofile = true
o.undodir = vim.fn.stdpath("data") .. "/undo"

-- Performance
o.updatetime = 250
o.timeoutlen = 300

-- Misc
o.wrap = false
o.clipboard = "unnamedplus"
o.mouse = "a"
o.completeopt = { "menu", "menuone", "noselect" }

-- Go uses real tabs
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
    end,
})

-- LaTeX: wrap prose at 100 chars
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex", "latex" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.colorcolumn = ""
    end,
})
