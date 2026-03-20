local M = {}

local lspFormat = require("lsp-format")
-- When doing `:wq`, vim may quit before the format runs, since lsp-format runs
-- asynchronously. Run it sync instead in that case.
vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]
vim.cmd [[cabbrev wqa execute "Format sync" <bar> wqa]]


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
vim.lsp.config('efm', {
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
    -- Enable formatting on save
    lspFormat.on_attach(client, bufnr)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format()<CR>', {})

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
})
vim.lsp.enable('efm')

return M
