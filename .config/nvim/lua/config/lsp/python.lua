local M = {}

function M.setup()
  local filetypes = { "python" }
  local python_root_markers = {
    ".git",
    "pyproject.toml",
    "setup.py",
    "requirements.txt",
    "Pipfile",
    "mise.toml",
  }
  local capabilities = require("config.lsp.utils").make_client_capabilities()

  vim.lsp.config("basedpyright", {
    name = "basedpyright",
    cmd = { "basedpyright-langserver", "--stdio" },
    capabilities = capabilities,
    root_markers = python_root_markers,
    filetypes = filetypes,
    settings = {
      -- Use efm for formatters
      pyright = {
        disableOrganizeImports = true,
      },
      -- python = {
      --   analysis = {
      --     ignore = { "*" },
      --   },
      -- },
    },
  })
  vim.lsp.enable("basedpyright")

  vim.lsp.config("ruff", {
    name = "ruff",
    cmd = { "ruff", "server" },
    capabilities = capabilities,
    root_markers = python_root_markers,
    filetypes = filetypes,
  })
  vim.lsp.enable("ruff")
end

return M
