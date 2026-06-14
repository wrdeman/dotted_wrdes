require("lualine").setup({
    options = {
        theme            = "gruvbox",
        globalstatus     = true,   -- single statusline across all splits
        component_separators = { left = "", right = "" },
        section_separators   = { left = "", right = "" },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },   -- relative path
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    extensions = { "nvim-tree", "quickfix", "fugitive" },
})
