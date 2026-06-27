local M = {}

function M.setup()
  local capabilities = require("config.lsp.utils").make_client_capabilities()

  vim.lsp.config("rust_analyzer", {
    name = { "rust_analyzer" },
    filetypes = { "rust" },
    capabilities = capabilities,
    root_markers = require('config.lsp.constants'),
    flags = {
      debounce_text_changes = 200,
    },
  })

  vim.lsp.enable("rust_analyzer")
end

return M
