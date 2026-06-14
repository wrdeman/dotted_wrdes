-- Space as leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Navigation
map("n", "<C-h>", "<C-w>h", "Move to left split")
map("n", "<C-l>", "<C-w>l", "Move to right split")
map("n", "<C-j>", "<C-w>j", "Move to lower split")
map("n", "<C-k>", "<C-w>k", "Move to upper split")

-- File explorer
map("n", "<leader>e", ":NvimTreeToggle<CR>", "Toggle file tree")
map("n", "<leader>E", ":NvimTreeFindFile<CR>", "Reveal file in tree")

-- Buffer management
map("n", "<leader>bd", ":bd<CR>", "Delete buffer")
map("n", "[b", ":bprev<CR>", "Previous buffer")
map("n", "]b", ":bnext<CR>", "Next buffer")

-- Quick-save and quit
map("n", "<leader>w", ":w<CR>", "Save")
map("n", "<leader>q", ":q<CR>", "Quit")

-- Move selected lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")

-- Keep cursor centred when jumping
map("n", "<C-d>", "<C-d>zz", "Scroll down (centred)")
map("n", "<C-u>", "<C-u>zz", "Scroll up (centred)")
map("n", "n", "nzzzv", "Next search result (centred)")
map("n", "N", "Nzzzv", "Prev search result (centred)")

-- LSP (also set in lsp.lua on_attach, but useful to have here as reference)
map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
map("n", "K", vim.lsp.buf.hover, "LSP hover")
map("n", "gd", vim.lsp.buf.definition, "Go to definition")
map("n", "gr", vim.lsp.buf.references, "Go to references")
map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
map("n", "<leader>d", vim.diagnostic.open_float, "Show diagnostics")
