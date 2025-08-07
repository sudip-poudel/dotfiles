return {
	-- lspconfig
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason.nvim",
			{ "williamboman/mason-lspconfig.nvim", config = function() end },
		},
		opts = function()
			local ret = {
				-- options for vim.diagnostic.config()
				diagnostics = {
					underline = true,
					update_in_insert = false,
					virtual_text = {
						spacing = 4,
						source = "if_many",
						prefix = "●",
					},
					severity_sort = true,
					signs = {
						text = {
							[vim.diagnostic.severity.ERROR] = "✘",
							[vim.diagnostic.severity.WARN] = "▲",
							[vim.diagnostic.severity.HINT] = "⚑",
							[vim.diagnostic.severity.INFO] = "»",
						},
					},
				},
				-- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
				inlay_hints = {
					enabled = true,
					exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
				},
				-- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
				codelens = {
					enabled = false,
				},
				-- add any global capabilities here
				capabilities = {
					workspace = {
						fileOperations = {
							didRename = true,
							willRename = true,
						},
					},
				},
				-- options for vim.lsp.buf.format
				format = {
					formatting_options = nil,
					timeout_ms = nil,
				},
				-- LSP Server Settings
				servers = {
					lua_ls = {
						settings = {
							Lua = {
								workspace = {
									checkThirdParty = false,
								},
								codeLens = {
									enable = true,
								},
								completion = {
									callSnippet = "Replace",
								},
								doc = {
									privateName = { "^_" },
								},
								hint = {
									enable = true,
									setType = false,
									paramType = true,
									paramName = "Disable",
									semicolon = "Disable",
									arrayIndex = "Disable",
								},
							},
						},
					},
					-- Python
					pyright = {},
					ruff = {
						cmd_env = {
							RUFF_TRACE = "messages",
						},
						init_options = {
							settings = {
								logLevel = "error",
							},
						},
					},
					-- JavaScript/TypeScript
					ts_ls = {},
					eslint = {
						settings = {
							workingDirectories = { mode = "auto" },
						},
					},
					-- Web development
					html = {},
					cssls = {},
					emmet_ls = {},
					-- JSON/YAML
					jsonls = {},
					yamlls = {},
					-- Bash
					bashls = {},
					-- Go
					gopls = {},
					-- Rust
					rust_analyzer = {},
					-- C/C++
					clangd = {},
					-- Docker
					dockerls = {},
					-- Markdown
					marksman = {},
				},
				setup = {},
			}
			return ret
		end,
		config = function(_, opts)
			-- setup keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(args)
					local buffer = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "ruff" then
						-- Disable hover in favor of Pyright
						client.server_capabilities.hoverProvider = false
					end

					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
					end

					map("n", "gd", require("telescope.builtin").lsp_definitions, "Goto Definition")
					map("n", "gr", require("telescope.builtin").lsp_references, "References")
					map("n", "gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
					map("n", "gy", require("telescope.builtin").lsp_type_definitions, "Goto T[y]pe Definition")
					map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
					map("n", "K", vim.lsp.buf.hover, "Hover")
					map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
					map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("n", "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
					map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
					map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
					-- map("n", "<leader>cf", function()
					-- 	vim.lsp.buf.format({ async = true })
					-- end, "Format Document")
					-- map("v", "<leader>cf", function()
					-- 	vim.lsp.buf.format({ async = true })
					-- end, "Format Range")

					-- Document highlight keymaps
					map("n", "<leader>ch", function()
						if vim.b.document_highlight_enabled then
							vim.lsp.buf.clear_references()
							vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
							vim.b.document_highlight_enabled = false
							print("Document highlight disabled")
						else
							if client and client.supports_method("textDocument/documentHighlight") then
								vim.lsp.buf.document_highlight()
								local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
								vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
									buffer = buffer,
									group = group,
									callback = vim.lsp.buf.document_highlight,
								})
								vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
									buffer = buffer,
									group = group,
									callback = vim.lsp.buf.clear_references,
								})
								vim.b.document_highlight_enabled = true
								print("Document highlight enabled")
							else
								print("Document highlight not supported by this LSP server")
							end
						end
					end, "Toggle Document Highlight")

					-- Enable document highlight by default for certain filetypes
					if client and client.supports_method("textDocument/documentHighlight") then
						local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = buffer,
							group = group,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = buffer,
							group = group,
							callback = vim.lsp.buf.clear_references,
						})
						vim.b.document_highlight_enabled = true
					end
				end,
			})

			-- diagnostics signs
			if vim.fn.has("nvim-0.10.0") == 0 then
				if type(opts.diagnostics.signs) ~= "boolean" then
					for severity, icon in pairs(opts.diagnostics.signs.text) do
						local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
						name = "DiagnosticSign" .. name
						vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
					end
				end
			end

			if vim.fn.has("nvim-0.10") == 1 then
				-- inlay hints
				if opts.inlay_hints.enabled then
					vim.api.nvim_create_autocmd("LspAttach", {
						callback = function(args)
							local buffer = args.buf
							local client = vim.lsp.get_client_by_id(args.data.client_id)
							if client and client.supports_method("textDocument/inlayHint") then
								if
									vim.api.nvim_buf_is_valid(buffer)
									and vim.bo[buffer].buftype == ""
									and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
								then
									vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
								end
							end
						end,
					})
				end

				-- code lens
				if opts.codelens.enabled and vim.lsp.codelens then
					vim.api.nvim_create_autocmd("LspAttach", {
						callback = function(args)
							local buffer = args.buf
							local client = vim.lsp.get_client_by_id(args.data.client_id)
							if client and client.supports_method("textDocument/codeLens") then
								vim.lsp.codelens.refresh()
								vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
									buffer = buffer,
									callback = vim.lsp.codelens.refresh,
								})
							end
						end,
					})
				end
			end

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			-- Add buffer validation for diagnostics
			local original_show = vim.diagnostic.show
			vim.diagnostic.show = function(namespace, bufnr, diagnostics, opts_inner)
				if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
					return original_show(namespace, bufnr, diagnostics, opts_inner)
				end
			end

			local servers = opts.servers
			local has_blink, blink = pcall(require, "blink.cmp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				has_blink and blink.get_lsp_capabilities() or {},
				opts.capabilities or {}
			)

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})
				if server_opts.enabled == false then
					return
				end

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end
				require("lspconfig")[server].setup(server_opts)
			end

			-- get all the servers that are available through mason-lspconfig
			local have_mason, mlsp = pcall(require, "mason-lspconfig")
			local all_mslp_servers = {}
			if have_mason then
				all_mslp_servers = mlsp.get_available_servers()
			end

			local ensure_installed = {}
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					if server_opts.enabled ~= false then
						if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
							setup(server)
						else
							ensure_installed[#ensure_installed + 1] = server
						end
					end
				end
			end

			if have_mason then
				mlsp.setup({
					ensure_installed = ensure_installed,
					handlers = { setup },
				})
			end
		end,
	},

	-- cmdline tools and lsp servers
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				"stylua",
				"shfmt",
				"lua-language-server",
				"pyright",
				"typescript-language-server",
				"eslint-lsp",
				"html-lsp",
				"css-lsp",
				"emmet-ls",
				"json-lsp",
				"yaml-language-server",
				"bash-language-server",
				"gopls",
				"rust-analyzer",
				"clangd",
				"dockerfile-language-server",
				"marksman",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(function()
					-- trigger FileType event to possibly load this newly installed LSP server
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)

			mr.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end)
		end,
	},
}
