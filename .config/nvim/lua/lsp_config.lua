-- local null_ls = require("null-ls")
-- null_ls.setup({
--     sources = {
--         null_ls.builtins.formatting.stylua,
--         -- null_ls.builtins.diagnostics.eslint,
--         null_ls.builtins.completion.spell,
--     },
-- })

local lspUtils = require('lspconfig.util')

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

-- LSP Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local buf = ev.buf

    -- Enable completion triggered by <c-x><c-o>
    if client.server_capabilities.completionProvider then
      vim.bo[buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    end
    if client.server_capabilities.definitionProvider then
      vim.bo[buf].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    -- some more autocmds
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
          buffer = buf,
          callback = function()
            vim.lsp.buf.document_highlight()
          end,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = buf,
          callback = function()
            vim.lsp.buf.clear_references()
          end,
        })
    end

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    end
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    if client.server_capabilities.signatureHelpProvider then
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    end
    if client.server_capabilities.workspace.workspaceFolders then
      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
      vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, opts)
    end
    if client.server_capabilities.typeDefinitionProvider then
      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    end
    if client.server_capabilities.renameProvider then
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    end
    if client.server_capabilities.codeActionProvider then
      vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    end
    if client.server_capabilities.referencesProvider then
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    end
    if client.server_capabilities.document_formatting then
        vim.keymap.set('n', '<leader>f', function()
          vim.lsp.buf.format { async = true }
        end, opts)
        -- format on save
        --[[
        if client.name == 'efm' then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = buf,
            command = 'lua vim.lsp.buf.format()',
          })
        end
        ]]--
    end
  end,
})


-- Connect lspconfig to nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- local servers = { 'pyright', 'rust_analyzer', 'tsserver', 'eslint'}
local servers = {'pyright', 'rust_analyzer'}
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    capabilities = capabilities,
    -- The default config looks for language-specific configs, which doesn't always work
    -- well if we have nested patterns (like we do in external-web). Instead, use git.
    root_dir = lspUtils.root_pattern('.git'),
    on_attach = lspFormat.on_attach,
    flags = {
      debounce_text_changes = 250,
    }
  }
end

require('lspconfig')['eslint'].setup({
  settings = {packageManager = 'yarn'},
  root_dir = lspUtils.root_pattern('.git'),
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

-- Trying out replacing tsserver (typescript-language-server) with typescript-tools.
-- This does not yet have an lspconfig server defined by default (as of 6/22/23)
-- https://github.com/pmizio/typescript-tools.nvim
require("typescript-tools").setup {
  capabilities = capabilities,
  -- TODO: starting in the wrong parent directory (sub-app).
  -- is there something like: root_dir = lspUtils.root_pattern('.git') ?
  on_attach = function(client, bufnr)
      -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>TSToolsFixAll<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>TSToolsGoToSourceDefinition<CR>', opts)
      --[[
      vim.api.nvim_create_autocmd("InsertLeave", {
        buffer = bufnr,
        command = 'TSToolsAddMissingImports',
      })
      --]]
  end,
}

-- Specifying multiple will run them in parallel. This is good for linting
-- but bad for formatting.
local prettierd = {
  formatCommand = "prettierd --no-color '${INPUT}'",
  formatStdin = true,
}
local prettier = {
  formatCommand = "yarn -s prettier --loglevel silent "
    .. "${--range-start:charStart} ${--range-end:charEnd} '${INPUT}'",
  formatCanRange = true,
  formatStdin = true,
}
local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --stdin --fix-to-stdout --stdin-filename=${INPUT}",
  formatStdin = true
}
local css = {
  formatCommand = "yarn -s stylelint --fix",
  formatStdin = true,
  lintCommand = "yarn -s stylelint --no-color --formatter compact",
  lintStdin = true,
  lintFormats = { '%.%#: line %l, col %c, %trror - %m', '%.%#: line %l, col %c, %tarning - %m' },
}
local black = {
  formatCommand = 'black --no-color -q -',
  formatStdin = true,
}
local isort = {
  formatCommand = 'isort --quiet -',
  formatStdin = true,
}
local ruffFormat = {
  formatCommand = 'ruff format -s --stdin-filename -',
  formatStdin = true,
}
local ruffLintFix = {
  formatCommand = 'ruff check --fix-only -s --stdin-filename -',
  formatStdin = true,
}
local rustFormat = {
  formatCommand = 'rustfmt',
  formatStdin = true,
}
local efmLanguages = {
  javascript = {prettierd},
  typescript = {prettierd},
  javascriptreact = {prettierd},
  typescriptreact = {prettierd},
  css = {css, prettierd},
  scss = {css, prettierd},
  python = {ruffFormat, ruffLintFix},
  rust = {rustFormat}
}
require('lspconfig').efm.setup{
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
    codeAction = true,
  },
  settings = {
    rootMarkers = {".git/"},
    languages = efmLanguages,
    -- I don't think these are honored. Set values in ~/.config/efm-langserver
    -- in order to debug. logLevel > 1
    logFile = "/Users/brianlubars/.config/efm-langserver/debug.log",
    logLevel = 10,
    version = 2,
    lintDebounce = 1,
  },
  filetypes = vim.tbl_keys(efmLanguages),
  on_attach = function(client, bufnr)
    lspFormat.on_attach(client, bufnr)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format()<CR>', opts)

    --[[
    local group = vim.api.nvim_create_augroup('EfmFormat', {})
    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = bufnr,
      group = group,
      callback = function()
        vim.lsp.buf.format({timeout = 3000})
      end
    })
    --]]
  end,
}


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
