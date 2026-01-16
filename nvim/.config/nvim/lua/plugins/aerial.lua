return {
	{
		"stevearc/aerial.nvim",
		keys = {
			{
				"<leader>cs",
				function()
					require("aerial").toggle()
					local bufnr = vim.api.nvim_get_current_buf()
					require("aerial").tree_set_collapse_level(bufnr, 1)
				end,
				desc = "Aerial (Symbols)",
			},
		},
		opts = function()
			local icons = {
				Array = "󰅪",
				Boolean = "◩",
				Class = "󰠱",
				Color = "󰏘",
				Constant = "󰏿",
				Constructor = "",
				Enum = "",
				EnumMember = "",
				Event = "",
				Field = "󰜢",
				File = "󰈙",
				Folder = "󰉋",
				Function = "󰊕",
				Interface = "",
				Key = "",
				Keyword = "󰌋",
				Method = "󰆧",
				Module = "",
				Namespace = "󰌗",
				Null = "󰟢",
				Number = "󰎠",
				Object = "󰅩",
				Operator = "󰆕",
				Package = "󰏖",
				Property = "󰜢",
				Reference = "󰈇",
				Snippet = "",
				String = "󰉾",
				Struct = "󰙅",
				Text = "󰉿",
				TypeParameter = "󰗴",
				Unit = "󰑭",
				Value = "󰎠",
				Variable = "󰀫",
			}

			local filter_kind = {
				default = {
					"function",
					"method",
					"constructor",
					"class",
					"interface",
					"module",
					"struct",
					"enum",
					"type",
				},
			}

			local opts = {
				attach_mode = "window",
				backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
				show_guides = true,
				default_collapse_level = 1,
				layout = {
					resize_to_content = false,
					win_opts = {
						winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
						signcolumn = "yes",
						statuscolumn = " ",
					},
				},
				icons = icons,
				manage_folds = false,
				link_tree_to_folds = false,
				link_folds_to_tree = false,
				filter_kind = filter_kind,
				-- filter_kind = {
				-- 	"Class",
				-- 	"Constructor",
				-- 	"Enum",
				-- 	"Function",
				-- 	"Interface",
				-- 	"Method",
				-- 	"Module",
				-- 	"Namespace",
				-- 	"Struct",
				-- },
				-- optionally use on_attach to set keymaps when aerial has attached to a buffer
				on_attach = function(bufnr)
					-- require("aerial").tree_set_collapse_level(0, 1)
					-- Jump forwards/backwards with '{' and '}'
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
				end,
			}
			return opts
		end,
	},
}
