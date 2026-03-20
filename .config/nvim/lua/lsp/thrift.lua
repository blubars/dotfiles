local M = {}

local capabilities = require('lsp.utils').make_client_capabilities()
local root_markers = require('lsp.constants').root_markers

vim.lsp.config('rapacity', {
  filetypes = { 'thrift' },
  root_markers = root_markers,
  capabilities = capabilities,
  cmd = { 'rapacity', 'lsp', '--stdio' },
})

vim.lsp.enable('rapacity')

return M
