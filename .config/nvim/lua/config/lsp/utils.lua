local M = {}

function M.make_client_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local cmp_lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
  return vim.tbl_deep_extend("keep", capabilities, cmp_lsp_capabilities)
end

return M
