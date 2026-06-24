local cmp = require("cmp")
local luasnip = require("luasnip")

-- Load VS Code-style snippets (friendly-snippets)
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    window = {
        completion    = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },

    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"]     = cmp.mapping.abort(),
        ["<CR>"]      = cmp.mapping.confirm({ select = false }),
        -- Tab cycles through suggestions; Shift-Tab reverses
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),

    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
    }, {
        { name = "buffer", keyword_length = 3 },
        { name = "path" },
    }),

    formatting = {
        format = function(entry, item)
            -- Label the source in the completion menu
            local source_labels = {
                nvim_lsp = "[LSP]",
                luasnip  = "[Snip]",
                buffer   = "[Buf]",
                path     = "[Path]",
                gitmoji  = "[Emoji]",
            }
            item.menu = source_labels[entry.source.name] or ""
            return item
        end,
    },

    experimental = { ghost_text = true },
})

-- Gitmoji source (Dynge/gitmoji.nvim) only in commit messages. Scoped to
-- gitcommit so the `:` trigger doesn't pollute normal-buffer completion.
cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "gitmoji" },
        { name = "buffer", keyword_length = 3 },
        { name = "path" },
    }),
})
