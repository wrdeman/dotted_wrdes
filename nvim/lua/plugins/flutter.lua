require("flutter-tools").setup({
    -- Use the fvm-managed SDK (<project>/.fvm/flutter_sdk) when present.
    -- Matches the shell workflow (fvm use / fvm flutter ...).
    fvm = true,

    -- dartls is set up by flutter-tools (not Mason / nvim-lspconfig). Wire in
    -- nvim-cmp completion capabilities; the buffer-local LSP keymaps (gd, gr,
    -- K, <leader>rn, <leader>ca, ...) come from the shared LspAttach autocmd
    -- in plugins/lsp.lua, which fires for dartls too.
    lsp = {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
    },

    -- Debugging via nvim-dap (configured in plugins/dap.lua). The Dart/Flutter
    -- debug adapter ships with the SDK, so no extra Mason tool is needed.
    debugger = {
        enabled = true,
        run_via_dap = true,
        register_configurations = function(_)
            require("dap.ext.vscode").load_launchjs()
        end,
    },

    widget_guides = { enabled = true },
})

-- flutter-tools registers its :Flutter* commands lazily, on the first BufEnter
-- of a dart file (an internal `once` autocmd in the FlutterToolsGroup). But lazy
-- loads this plugin *on* the dart FileType/BufEnter, so that BufEnter can already
-- be spent by the time the autocmd is registered — leaving the buffer that
-- triggered the load without the commands (E492: Not an editor command: FlutterRun).
-- Re-emit BufEnter for the current (dart) buffer so registration runs now.
pcall(vim.api.nvim_exec_autocmds, "BufEnter", { group = "FlutterToolsGroup" })
