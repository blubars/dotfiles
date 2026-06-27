local M = {}

function M.setup()
  local capabilities = require("config.lsp.utils").make_client_capabilities()
  local root_markers = require("config.lsp.constants").root_markers

  vim.lsp.config("rapacity", {
    filetypes = { "thrift" },
    root_markers = root_markers,
    capabilities = capabilities,
    cmd = { "rapacity", "lsp", "--stdio" },
  })

  vim.lsp.enable("rapacity")
end

return M
