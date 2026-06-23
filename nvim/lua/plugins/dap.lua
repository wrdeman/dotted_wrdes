local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Open the UI when a session starts, close it when it ends
dap.listeners.before.attach.dapui_config           = function() dapui.open() end
dap.listeners.before.launch.dapui_config           = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config     = function() dapui.close() end

-- Language adapters. Binaries are installed by mason-tool-installer (delve,
-- debugpy) — keep that ensure_installed list in sync.
require("dap-go").setup()
require("dap-python").setup(
    vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
)

-- Project-specific launch configs auto-read from <project>/.vscode/launch.json (see :help dap-providers)

-- Gutter signs
vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn",  linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticInfo",  linehl = "Visual", numhl = "" })

local map = function(keys, fn, desc)
    vim.keymap.set("n", keys, fn, { silent = true, desc = desc })
end

map("<leader>db", dap.toggle_breakpoint, "DAP toggle breakpoint")
map("<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, "DAP conditional breakpoint")
map("<leader>dc", dap.continue,    "DAP continue / start")
map("<leader>di", dap.step_into,   "DAP step into")
map("<leader>do", dap.step_over,   "DAP step over")
map("<leader>dO", dap.step_out,    "DAP step out")
map("<leader>dr", dap.repl.toggle, "DAP toggle REPL")
map("<leader>dl", dap.run_last,    "DAP run last")
map("<leader>du", dapui.toggle,    "DAP toggle UI")
map("<leader>dt", dap.terminate,   "DAP terminate")
