local capabilities = require('lsp.utils').make_client_capabilities()
local lspUtils = require('lspconfig.util')

vim.lsp.config('rust_analyzer', {
  name = {'rust_analyzer'},
  filetypes = {'rust'},
  capabilities = capabilities,
  root_dir = lspUtils.root_pattern('.git'),
  flags = {
    debounce_text_changes = 200,
  }
})
vim.lsp.enable('rust_analyzer')
