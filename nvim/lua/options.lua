-- Ensure Go toolchain and installed binaries are on PATH for Mason installers.
-- Needed when nvim is launched from a shell that hasn't sourced .zshrc (e.g.
-- desktop launchers, tmux sessions started before PATH was updated).
do
    local home = vim.uv.os_homedir()
    local extra_paths = {
        home .. "/.local/bin",   -- nvim, ruff, lazygit, hurl, etc.
        home .. "/.local/go/bin", -- go toolchain (Mason needs this for Go LSP installs)
        home .. "/go/bin",        -- go-installed binaries
    }
    local path = vim.env.PATH or ""
    for _, p in ipairs(extra_paths) do
        if vim.uv.fs_stat(p) and not path:find(p, 1, true) then
            vim.env.PATH = p .. ":" .. vim.env.PATH
        end
    end
end

-- Disable unused providers (suppresses checkhealth warnings for Perl/Ruby/Node)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Point the Python provider at the dedicated pynvim venv (created by install.sh)
local pynvim_python = vim.fn.expand("~/.local/share/nvim/pynvim-venv/bin/python3")
if vim.uv.fs_stat(pynvim_python) then
    vim.g.python3_host_prog = pynvim_python
end

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
