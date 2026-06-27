require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands").setup()
require("config.highlights").setup()
require("config.lazy")
require("config.llm").setup()
-- since some config.lsp depends on plugins, the module is loaded by lazy.
-- there's probably a better way to organize the packages to reflect that.

-- I change these a lot, so just throw them here.
