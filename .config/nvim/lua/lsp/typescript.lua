local capabilities = require('lsp.utils').make_client_capabilities()
local filetypes = {
  'javascript',
  'typescript',
  'javascriptreact',
  'typescriptreact',
  'css',
  'scss',
}

-- Trying out replacing tsserver (typescript-language-server) with typescript-tools.
-- This does not yet have an lspconfig server defined by default (as of 6/22/23)
-- https://github.com/pmizio/typescript-tools.nvim
require("typescript-tools").setup({
  capabilities = capabilities,
})

-- I'm using this to have sequential formatters run: eslint, then prettier.
-- It sounds like there may also be native support? Should try it, though
-- didn't see it in the API docs.
-- https://github.com/neovim/neovim/pull/14462
local lspFormat = require("lsp-format")
-- run prettier (efm) after eslint
local tsFormatOrder = {'eslint', 'efm'}
lspFormat.setup {
  javascript= {sync = true, order = tsFormatOrder},
  typescript = {sync = true, order = tsFormatOrder},
  javascriptreact = {sync = true, order = tsFormatOrder},
  typescriptreact = {sync = true, order = tsFormatOrder},
}

vim.lsp.config('eslint', {
  settings = {packageManager = 'yarn'},
  -- root_dir = lspUtils.root_pattern('.git'),
  rootMarkers = {".git"},
  capabilities = capabilities,
  filetypes = filetypes,
  on_attach = function(client, bufnr)
    -- this is hacky...
    client.server_capabilities.documentFormattingProvider = true
    lspFormat.on_attach(client, bufnr)
    --[[
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = 'EslintFixAll',
    })
    --]]
  end,
})
vim.lsp.enable('eslint')

--[[
-- Formatter configurations will be executed in order
local formatUtils = require('formatter.util')

function formatPrettier()
    return {
      exe = "yarn run -s prettier",
      args = {
        "--stdin-filepath", -- vim.api.nvim_buf_get_name(0)
        formatUtils.escape_path(formatUtils.get_current_buffer_file_path()),
      },
      stdin = true,
      cwd = lspUtils.root_pattern(".git")(),
    }
end

-- irritatingly, this is async so it interferes with other formatters
require('formatter').setup {
  logging = true,
  log_level = vim.log.levels.DEBUG,
  filetype = {
    javascript = {formatPrettier},
    typescript = {formatPrettier},
    typescriptreact = {formatPrettier},
    lua = {
      -- "formatter.filetypes.lua" defines default configurations for the
      -- "lua" filetype
      require("formatter.filetypes.lua").stylua,
    },
  }
}
--]]


