-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- Import plugin configurations
		{ import = "plugins" },
	},
	defaults = {
		lazy = false,
		version = false, -- always use the latest git commit
	},
	install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
	checker = { enabled = true }, -- automatically check for plugin updates
	performance = {
		rtp = {
			-- disable some rtp plugins
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- Load configuration
require("config.options")
require("config.keymaps")
require("nest_generator")
require("config.autocmds")

-- local function toggle_term()
-- 	require("terminal").toggle()
-- end
-- vim.keymap.set({ "n", "t" }, "<C-/>", toggle_term, { desc = "Toggle bottom terminal", silent = true })
--
-- vim.keymap.set({ "n", "t" }, "<C-_>", toggle_term, { desc = "Toggle bottom terminal", silent = true })
--
-- vim.keymap.set("n", "<leader>tt", toggle_term, { desc = "Toggle bottom terminal" })
-- vim.cmd.colorscheme("catppuccin")
