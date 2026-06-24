-- Bootstrap lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
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
			ensure_installed = { "gopls", "pyright", "lua_ls", "ruff" },
			automatic_installation = true,
		},
	},

	-- Auto-install formatters / debuggers (non-LSP tools Mason doesn't pull via
	-- mason-lspconfig). Keep this list in sync with conform.lua + dap.lua.
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = { "gofumpt", "goimports", "stylua", "delve", "debugpy" },
		},
	},

	-- LSP core
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("plugins.lsp")
		end,
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
		config = function()
			require("plugins.cmp")
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		config = function()
			require("plugins.treesitter")
		end,
	},

	-- LaTeX
	{
		"lervag/vimtex",
		ft = { "tex", "latex" },
		config = function()
			require("plugins.vimtex")
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("plugins.lualine")
		end,
	},

	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("plugins.nvim-tree")
		end,
	},

	-- Fuzzy finder (bonus — very useful alongside the above)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Native fzf sorter — much faster matching (needs `make` + a C compiler)
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
			{ "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
		},
		config = function()
			require("telescope").setup({ extensions = { fzf = {} } })
			require("telescope").load_extension("fzf")
		end,
	},

	-- Seamless split/pane navigation with tmux (pairs with the is_vim
	-- forwarding block in .tmux.conf). Moves nvim splits, then crosses
	-- into tmux panes at the edge.
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Nav split/pane left" },
			{ "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Nav split/pane down" },
			{ "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Nav split/pane up" },
			{ "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Nav split/pane right" },
			{ "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Nav last split/pane" },
		},
	},

	-- Git signs in the gutter
	{ "lewis6991/gitsigns.nvim", config = true },

	-- Lazygit TUI in a float (needs the `lazygit` binary — install.sh pulls it in)
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},

	-- Gitmoji completion in commit messages. Adds a `gitmoji` nvim-cmp source
	-- (wired up per-filetype in plugins/cmp.lua) that triggers on `:` while
	-- writing a gitcommit buffer.
	{
		"Dynge/gitmoji.nvim",
		dependencies = { "hrsh7th/nvim-cmp" },
		ft = "gitcommit",
		opts = {},
	},

	-- Auto-close brackets/quotes
	{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },

	-- Comment toggle (gcc / gc in visual)
	{ "numToStr/Comment.nvim", config = true },

	-- Formatter runner (black/isort via ruff, gofumpt+goimports, stylua).
	-- Owns format-on-save and <leader>f — replaces the old LSP format path.
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = { "n", "v" },
				desc = "Format buffer / selection",
			},
		},
		config = function()
			require("plugins.conform")
		end,
	},

	-- Debugging (DAP) — breakpoints, stepping, REPL, UI panels
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio", -- required by dap-ui
			"leoluz/nvim-dap-go", -- Go adapter (delve)
			"mfussenegger/nvim-dap-python", -- Python adapter (debugpy)
		},
		config = function()
			require("plugins.dap")
		end,
	},

	-- Flutter / Dart — dartls LSP, hot reload/restart, devices, DAP debugging.
	-- Uses the fvm-managed SDK (fvm = true in plugins/flutter.lua). Loads on
	-- dart files; <leader>fl* drives the run cycle.
	{
		"nvim-flutter/flutter-tools.nvim",
		ft = "dart",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		-- Maps are buffer-local to dart files, NOT a `keys` load-trigger: the
		-- :Flutter* commands only register once flutter-tools loads on a dart
		-- BufEnter, so a global mapping fired from a non-dart buffer would hit
		-- E492. This FileType autocmd is registered at startup (init runs eagerly)
		-- so it fires for every dart buffer, including the first.
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "dart",
				callback = function(ev)
					local map = function(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
					end
					map("<leader>flr", "<cmd>FlutterRun<cr>", "Flutter run")
					map("<leader>flR", "<cmd>FlutterRestart<cr>", "Flutter hot restart")
					map("<leader>flh", "<cmd>FlutterReload<cr>", "Flutter hot reload")
					map("<leader>flq", "<cmd>FlutterQuit<cr>", "Flutter quit")
					map("<leader>fld", "<cmd>FlutterDevices<cr>", "Flutter devices")
					map("<leader>fle", "<cmd>FlutterEmulators<cr>", "Flutter emulators")
					map("<leader>flo", "<cmd>FlutterOutlineToggle<cr>", "Flutter outline toggle")
					map("<leader>flD", "<cmd>FlutterDevTools<cr>", "Flutter DevTools")
					map("<leader>fll", "<cmd>FlutterLspRestart<cr>", "Flutter LSP restart")
				end,
			})
		end,
		config = function()
			require("plugins.flutter")
		end,
	},

	-- Keymap discoverability — popup of leader-key bindings
	{ "folke/which-key.nvim", event = "VeryLazy", opts = {} },

	-- Diagnostics / references / quickfix in a dedicated panel
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics (Trouble)" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list (Trouble)" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list (Trouble)" },
			{ "gR", "<cmd>Trouble lsp_references toggle<cr>", desc = "LSP references (Trouble)" },
		},
		opts = {},
	},

	-- Hurl — run HTTP requests from .hurl files and view responses in a split.
	-- Needs the `hurl` binary (install.sh pulls it in); json formatter uses `jq`.
	-- Highlighting comes from the `hurl` treesitter parser (treesitter.lua).
	{
		"jellydn/hurl.nvim",
		ft = "hurl",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			debug = false,
			show_notification = false,
			mode = "split",
			-- Env files passed to hurl as --variables-file. The plugin searches
			-- each name from the git root down to the .hurl file's own dir, so
			-- keep per-environment vars in sibling subdirs (e.g. http/local/,
			-- http/aDir/) — each holds its own local.private.vars, isolated
			-- because a sibling dir isn't in another's ancestor chain.
			env_file = { "local.private.vars", "vars.env" },
			formatters = {
				json = { "jq" }, -- pretty-print JSON responses (needs jq)
			},
		},
		keys = {
			{ "<leader>A", "<cmd>HurlRunner<cr>", desc = "Hurl run all requests" },
			{ "<leader>a", "<cmd>HurlRunnerAt<cr>", desc = "Hurl run request under cursor" },
			{ "<leader>te", "<cmd>HurlRunnerToEntry<cr>", desc = "Hurl run to entry" },
			{ "<leader>tE", "<cmd>HurlRunnerToEnd<cr>", desc = "Hurl run to end" },
			{ "<leader>tm", "<cmd>HurlToggleMode<cr>", desc = "Hurl toggle mode (split/popup)" },
			{ "<leader>tv", "<cmd>HurlVerbose<cr>", desc = "Hurl run verbose" },
			{ "<leader>tV", "<cmd>HurlVeryVerbose<cr>", desc = "Hurl run very verbose" },
			{ "<leader>h", ":HurlRunner<cr>", mode = "v", desc = "Hurl run selection" },
		},
	},
}, {
	ui = { border = "rounded" },
	checker = { enabled = false },
	rocks = { enabled = false }, -- disable luarocks (not needed for this setup)
})
