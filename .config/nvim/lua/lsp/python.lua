local filetypes = {'python'}
-- The default config looks for language-specific configs, which doesn't always work
-- well if we have nested patterns (like we do in external-web). Instead, prefer git.
local python_root_markers = {
  '.git',
  'pyproject.toml',
  'setup.py',
  'requirements.txt',
  'Pipfile',
  'mise.toml',
}

local capabilities = require('lsp.utils').make_client_capabilities()

vim.lsp.config('basedpyright', {
  name = 'basedpyright',
  cmd = { 'basedpyright-langserver', '--stdio' },
  capabilities = capabilities,
  root_markers = python_root_markers,
  filetypes = filetypes,
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use ruff for linting
        ignore = { '*' }
      }
    }
  }
})

vim.lsp.enable('basedpyright')

vim.lsp.config('ruff', {
  name = 'ruff',
  cmd = { 'ruff', 'server' },
  capabilities = capabilities,
  root_markers = python_root_markers,
  filetypes = filetypes,
})

vim.lsp.enable('ruff')
