local M = {}

-- Taken from https://www.reddit.com/r/neovim/comments/tjzmnt/better_lsp_rename/
function lsp_rename()
  local curr_name = vim.fn.expand("<cword>")
  local value = vim.fn.input("LSP Rename: ", curr_name)

  if not value or #value == 0 or curr_name == value then
    return
  end

  -- Get LSP request payload for thing under the cursor and set newName
  local lsp_params = vim.lsp.util.make_position_params()
  lsp_params.newName = value
  vim.lsp.buf_request_all(0, "textDocument/rename", lsp_params, function(res)
    if not res then
      return
    end

    -- print renames and add to quickfix list
    local changed_files_count = 0
    local changed_instances_count = 0
    local qflist = {}

    for client_id, client_res in pairs(res) do
      local workspace_edit = client_res.result
      if workspace_edit then
        -- apply rename
        local client = vim.lsp.get_client_by_id(client_id)
        vim.lsp.util.apply_workspace_edit(workspace_edit, client.offset_encoding)

        if workspace_edit.documentChanges then
          for _, changed_file in pairs(workspace_edit.documentChanges) do
            changed_files_count = changed_files_count + 1
            changed_instances_count = changed_instances_count + #changed_file.edits
            for _, edit in pairs(changed_file.edits) do
              table.insert(qflist, {
                filename = vim.uri_to_fname(changed_file.textDocument.uri),
                lnum = edit.range.start.line + 1,
              })
            end
          end
        elseif workspace_edit.changes then
          for uri, edits in pairs(workspace_edit.changes) do
            changed_files_count = changed_files_count + 1
            changed_instances_count = changed_instances_count + #edits
            for _, edit in pairs(edits) do
              table.insert(qflist, {
                filename = vim.uri_to_fname(uri),
                lnum = edit.range.start.line + 1,
              })
            end
          end
        end
      end
    end

    vim.fn.setqflist(qflist)
    vim.cmd("copen")
    print(string.format(
      "renamed %s instance%s in %s file%s. %s",
      changed_instances_count,
      changed_instances_count == 1 and "" or "s",
      changed_files_count,
      changed_files_count == 1 and "" or "s",
      changed_files_count > 1 and "To save them run ':wa'" or ""
    ))
  end)
end

function M.setup()
  -- Diagnostic mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.keymap.set("n", "<leader>e", function()
    vim.diagnostic.open_float({
      border = "rounded",
      title = " Diagnostics ",
    })
  end, { desc = "Line diagnostics" })
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

  -- Enable type inlay hints & keymap to toggle on/off
  vim.keymap.set("n", "<leader>i", function()
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  end, { desc = "Toggle inlay hints" })

  -- The main sauce.
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local buf = ev.buf

      if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
      end

      if client.server_capabilities.completionProvider then
        vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"
      end
      if client.server_capabilities.definitionProvider then
        vim.bo[buf].tagfunc = "v:lua.vim.lsp.tagfunc"
      end

      if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = buf,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = buf,
          callback = vim.lsp.buf.clear_references,
        })
      end

      local function keyopts(description)
        return { noremap = true, silent = true, buffer = buf, desc = description }
      end

      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, keyopts("Go to declaration"))
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, keyopts("Go to definition"))
      vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover({border = "rounded"})
      end, keyopts("Hover"))
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, keyopts("Go to implementation"))

      if client.server_capabilities.signatureHelpProvider then
        vim.keymap.set("n", "<C-k>", function()
          vim.lsp.buf.signature_help({border = "rounded"})
        end, keyopts("Signature help"))
      end
      if client.server_capabilities.workspace and client.server_capabilities.workspace.workspaceFolders then
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, keyopts("Add workspace folder"))
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, keyopts("Remove workspace folder"))
        vim.keymap.set("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, keyopts("List workspace folders"))
      end
      if client.server_capabilities.typeDefinitionProvider then
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, keyopts("Type definition"))
      end
      if client.server_capabilities.renameProvider then
        vim.keymap.set("n", "<leader>r", lsp_rename, keyopts("Rename symbol"))
      end
      if client.server_capabilities.codeActionProvider then
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, keyopts("Code actions"))
      end
      if client.server_capabilities.referencesProvider then
        vim.keymap.set("n", "gr", vim.lsp.buf.references, keyopts("References"))
      end
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      end
      if client.server_capabilities.documentFormattingProvider then
        vim.keymap.set("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, keyopts("Format buffer"))
      end
      if client.server_capabilities.codeLensProvider then
        local group = vim.api.nvim_create_augroup(string.format("lsp-%s-%s", buf, client.id), { clear = true })
        vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost", "TextChanged" }, {
          group = group,
          callback = function()
            vim.lsp.codelens.enable(true, { bufnr = buf })
          end,
          buffer = buf,
        })
        vim.lsp.codelens.enable(true, { bufnr = buf })
      end
    end,
  })

  require("config.lsp.efm").setup()
  require("config.lsp.python").setup()
  require("config.lsp.typescript").setup()
  require("config.lsp.rust").setup()
  require("config.lsp.thrift").setup()
end

return M
