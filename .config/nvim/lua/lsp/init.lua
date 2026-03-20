local M = {}

-- local null_ls = require("null-ls")
-- null_ls.setup({
--     sources = {
--         null_ls.builtins.formatting.stylua,
--         -- null_ls.builtins.diagnostics.eslint,
--         null_ls.builtins.completion.spell,
--     },
-- })

-- Copied from https://www.reddit.com/r/neovim/comments/tjzmnt/better_lsp_rename/
function LspRename()
  local curr_name = vim.fn.expand("<cword>")
  local value = vim.fn.input("LSP Rename: ", curr_name)
  local lsp_params = vim.lsp.util.make_position_params()

  if not value or #value == 0 or curr_name == value then return end

  -- request lsp rename
  lsp_params.newName = value
  vim.lsp.buf_request_all(0, "textDocument/rename", lsp_params, function(res)
    if not res then return end

    -- print renames and add to quickfix list
    local changed_files_count = 0
    local changed_instances_count = 0
    local qflist = {}

    for client_id, client_res in pairs(res) do
      workspace_edit = client_res.result
      -- apply renames
      local client = vim.lsp.get_client_by_id(client_id)
      vim.lsp.util.apply_workspace_edit(workspace_edit, client.offset_encoding)

      if (workspace_edit.documentChanges) then
        for _, changed_file in pairs(workspace_edit.documentChanges) do
          changed_files_count = changed_files_count + 1
          changed_instances_count = changed_instances_count + #changed_file.edits
          for _, edit in pairs(changed_file.edits) do
            table.insert(qflist, { filename = changed_file.textDocument.uri, lnum = edit.range.start.line + 1 })
          end
        end
      elseif (workspace_edit.changes) then
        for _, changed_file in pairs(workspace_edit.changes) do
          changed_files_count = changed_files_count + 1
          changed_instances_count = changed_instances_count + #changed_file
          for _, edit in pairs(changed_file.edits) do
            table.insert(qflist, { filename = changed_file.textDocument.uri, lnum = edit.range.start.line + 1 })
          end
        end
      end
    end

    vim.fn.setqflist(qflist)
    vim.cmd("copen")

    -- compose the right print message
    print(string.format("renamed %s instance%s in %s file%s. %s",
      changed_instances_count,
      changed_instances_count == 1 and '' or 's',
      changed_files_count,
      changed_files_count == 1 and '' or 's',
      changed_files_count > 1 and "To save them run ':wa'" or ''
    ))
  end)
end

-- LSP Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local buf = ev.buf

    if client.name == 'ruff' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end

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

    local function keyopts(description)
      return { noremap = true, silent = true, buffer = bufnr, desc = description }
    end

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, keyopts('lsp [g]o to [D]eclaration'))
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, keyopts(''))
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, keyopts('lsp hover'))
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, keyopts('lsp [g]o to [i]mplementation'))
    if client.server_capabilities.signatureHelpProvider then
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, keyopts('lsp signature help'))
    end
    if client.server_capabilities.workspace and client.server_capabilities.workspace.workspaceFolders then
      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, keyopts(''))
      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, keyopts(''))
      vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, keyopts('lsp [w]orkspace folders [l]ist'))
    end
    if client.server_capabilities.typeDefinitionProvider then
      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, keyopts(''))
    end
    if client.server_capabilities.renameProvider then
      -- vim.keymap.set('n', '<space>r', vim.lsp.buf.rename, keyopts(''))
      vim.keymap.set('n', '<space>r', LspRename)
    end
    if client.server_capabilities.codeActionProvider then
      vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, keyopts(''))
    end
    if client.server_capabilities.referencesProvider then
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, keyopts(''))
    end

    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    if client.server_capabilities.document_formatting then
        vim.keymap.set('n', '<leader>f', function()
          vim.lsp.buf.format { async = true }
        end, keyopts(''))
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

    -- Auto-refresh code lenses
    if client and client.server_capabilities.codeLensProvider then
      local group = api.nvim_create_augroup(string.format('lsp-%s-%s', bufnr, client.id), {})
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufWritePost', 'TextChanged' }, {
        group = group,
        callback = function()
          vim.lsp.codelens.refresh { bufnr = bufnr }
        end,
        buffer = bufnr,
      })
      vim.lsp.codelens.refresh { bufnr = bufnr }
    end
  end,
})

-- Toggle inlay hints keymap (global)
vim.keymap.set('n', '<leader>i', function()
  local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = 0 }
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
end)

require('lsp.utils')
require('lsp.global')
require('lsp.python')
require('lsp.typescript')
require('lsp.rust')
require('lsp.thrift')

return M
