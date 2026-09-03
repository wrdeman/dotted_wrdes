-- octo.nvim configuration — GitHub issues / PRs / code review inside nvim.
--
-- All GitHub traffic goes through the `gh` CLI (install.sh pulls it in), so
-- there is no token in this repo: authentication is whatever `gh auth login`
-- has already set up. Run `:checkhealth octo` if something looks wrong.
--
-- Picker is telescope (already a dependency of this config). See nvim-octo.md
-- for the review / comment / approve workflow.

require("octo").setup({
    picker = "telescope",

    -- A bare `:Octo` opens a picker of every available action — the discovery
    -- entry point, so the <leader>o* maps only need to cover the common lists.
    enable_builtin = true,

    -- Try `upstream` before `origin` so a fork's PRs resolve against the
    -- upstream repo (octo's default order, kept explicit).
    default_remote = { "upstream", "origin" },

    reviews = {
        auto_show_threads = true, -- pop existing threads open as the cursor moves
        focus = "right",          -- start on the new (right) side of the diff
    },

    -- Show which lines you have already reviewed / modified in the number
    -- column rather than the sign column (the sign column is gitsigns').
    ui = { use_signcolumn = false, use_statuscolumn = true },

    mappings = {
        submit_win = {
            -- Octo's default for comment_review is `<C-m>`, which a terminal
            -- sends as carriage return — byte-identical to <CR>, so nvim cannot
            -- tell it from Enter. These maps are normal-mode only, so pressing
            -- Esc after writing the review body and then hitting Enter would
            -- submit it with no verdict. Move it somewhere deliberate.
            comment_review = { lhs = "<C-y>", desc = "comment review (no verdict)", mode = { "n" } },
        },

        pull_request = {
            -- Octo's default for approve_pr is `<leader>qa`, which collides with
            -- the global `<leader>q` (:q) — pressing <space>q in a PR buffer
            -- would stall waiting for a possible `a`. Move approve into the
            -- `p`(ull request) namespace on localleader like its siblings.
            approve_pr = { lhs = "<localleader>pa", desc = "approve PR" },
        },
    },
})

-- Octo buffers are GitHub-flavoured markdown; render them with the markdown
-- parser (needs the `markdown` + `markdown_inline` parsers — see treesitter.lua).
vim.treesitter.language.register("markdown", "octo")
