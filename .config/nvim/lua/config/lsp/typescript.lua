local M = {}

function M.setup()
  local capabilities = require("config.lsp.utils").make_client_capabilities()

  local filetypes = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "css",
    "scss",
  }

  vim.lsp.config("vtsls", {
    cmd = { "vtsls", "--stdio" },
    capabilities = capabilities,
    filetypes = filetypes,
    root_markers = {
      "tsconfig.json",
      "jsconfig.json",
      "package.json",
      ".git",
    },
    on_attach = function(client)
      -- Keep formatting delegated to eslint/efm.
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  })
  vim.lsp.enable("vtsls")

  vim.lsp.config("oxfmt", {
    cmd = { "yarn", "oxfmt", "--lsp" },
    root_markers = { ".git" },
    -- capabilities = capabilities,
    filetypes = filetypes,
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = true

      local group = vim.api.nvim_create_augroup(string.format("oxfmt-format-%d", bufnr), { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            async = false,
            filter = function(c)
              return c.name == "oxfmt"
            end,
          })
        end,
      })
    end,

  })
  vim.lsp.enable("oxfmt")

  -- https://github.com/hrsh7th/vscode-langservers-extracted
  -- npm i -g vscode-langservers-extracted
  vim.lsp.config("eslint", {
    cmd = { "vscode-eslint-language-server", "--stdio" },
    root_markers = { ".git" },
    capabilities = capabilities,
    filetypes = filetypes,
    -- Refer to https://github.com/Microsoft/vscode-eslint#settings-options for documentation.
    ---@type lspconfig.settings.eslint
    settings = {
      settings = { packageManager = "yarn" },
      validate = 'on',
      useESLintClass = false,
      experimental = {},
      codeActionOnSave = {
        enable = false,
        mode = 'all',
      },
      format = false,
      quiet = false,
      onIgnoredFiles = 'off',
      rulesCustomizations = {},
      run = 'onType',
      problems = {
        shortenToSingleLine = false,
      },
      -- nodePath configures the directory in which the eslint server should start its node_modules resolution.
      -- This path is relative to the workspace folder (root dir) of the server instance.
      nodePath = '',
      -- use the workspace folder location or the file location (if no workspace folder is open) as the working directory
      workingDirectory = { mode = 'auto' },
      codeAction = {
        disableRuleComment = {
          enable = true,
          location = 'separateLine',
        },
        showDocumentation = {
          enable = true,
        },
      },
    },
    on_attach = function(client)
      -- Disable formatting so oxfmt is the only JS/TS formatter.
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  })

  vim.lsp.enable("eslint")


end

return M
