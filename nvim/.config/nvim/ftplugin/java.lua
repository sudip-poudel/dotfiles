local jdtls = require("jdtls")
local home = os.getenv("HOME")

-- 1. Root directory detection
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = jdtls.setup.find_root(root_markers)

-- 2. Project-specific workspace cache
-- This avoids the "Workspace already in use" error
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

-- 3. Path to the jdtls installation (installed via Mason)
local mason_path = home .. "/.local/share/nvim/mason/packages/jdtls"
local lombok_path = mason_path .. "/lombok.jar"

local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",

		-- Quirks: Lombok Support
		"-javaagent:" .. lombok_path,

		-- Point to the jar launcher (Mason path)
		"-jar",
		vim.fn.glob(mason_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),

		-- Point to the configuration (Linux/Mac/Win quirk)
		"-configuration",
		mason_path .. "/config_linux", -- Change to config_mac or config_win if needed

		"-data",
		workspace_dir,
	},
	root_dir = root_dir,
	settings = {
		java = {
			signatureHelp = { enabled = true },
			completion = {
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
				},
			},
		},
	},
}

-- Keymaps (specific to Java LSP)
local on_attach = function(client, bufnr)
	local opts = { silent = true, buffer = bufnr }
	vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, opts)
	vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, opts)
	vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, opts)
	vim.keymap.set("v", "<leader>jm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], opts)
end

config["on_attach"] = on_attach

-- Start the LSP
jdtls.start_or_attach(config)
