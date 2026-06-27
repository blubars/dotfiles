local M = {}

-- I use EFM for formatting.
function M.setup()
  local lsp_format = require("lsp-format")

  -- When doing `:wq`, vim may quit before the format runs, since lsp-format runs
  -- asynchronously. Run it sync instead in that case.
  vim.cmd([[cabbrev wq execute "Format sync" <bar> wq]])
  vim.cmd([[cabbrev wqa execute "Format sync" <bar> wqa]])

  local eslint = {
    lintCommand = "eslint --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
    lintIgnoreExitCode = true,
    formatCommand = "eslint --fix-to-stdout --stdin --stdin-filename=${INPUT}",
    formatStdin = true
  }

  local prettierd = {
    formatCommand = "prettierd --no-color '${INPUT}'",
    formatStdin = true,
  }

  local css = {
    formatCommand = "yarn -s stylelint --fix",
    formatStdin = true,
    lintCommand = "yarn -s stylelint --no-color --formatter compact",
    lintStdin = true,
    lintFormats = {
      "%.%#: line %l, col %c, %trror - %m",
      "%.%#: line %l, col %c, %tarning - %m",
    },
  }

  local ruff_format = {
    formatCommand = "ruff format -s --stdin-filename -",
    formatStdin = true,
  }

  local ruff_lint_fix = {
    formatCommand = "ruff check --fix-only -s --stdin-filename -",
    formatStdin = true,
  }

  local rust_format = {
    formatCommand = "rustfmt",
    formatStdin = true,
  }

  -- Specifying multiple will run them in parallel. This is good for linting
  -- but bad for formatting.
  local efm_languages = {
    css = { css },
    scss = { css },
    python = { ruff_format, ruff_lint_fix },
    rust = { rust_format },
  }

  vim.lsp.config("efm", {
    cmd = { 'efm-langserver' },
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = true,
    },
    settings = {
      rootMarkers = { ".git/" },
      languages = efm_languages,
      version = 2,
      lintDebounce = 5,
    },
    filetypes = vim.tbl_keys(efm_languages),
    on_attach = function(client, bufnr)
      lsp_format.on_attach(client, bufnr)
    end,
    root_markers = require("config.lsp.constants").root_markers,
  })

  vim.lsp.enable("efm")
end

return M
