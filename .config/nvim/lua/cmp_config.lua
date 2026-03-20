-- Set up nvim-cmp.
local cmp = require('cmp')
local lspkind = require('lspkind')
local snippy = require('snippy')

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end

---- Comparators for sorting completion options ----
-- https://www.reddit.com/r/neovim/comments/14k7pbc/what_is_the_nvimcmp_comparatorsorting_you_are/
-- should return True if first entry should come earlier
local lspkind_comparator = function(conf)
  local lsp_types = require('cmp.types').lsp

  return function(entry1, entry2)
    if entry1.source.name ~= 'nvim_lsp' then
      if entry2.source.name == 'nvim_lsp' then
        return false
      else
        return nil
      end
    end
    local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
    local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]

    local priority1 = conf.kind_priority[kind1] or 0
    local priority2 = conf.kind_priority[kind2] or 0
    if priority1 == priority2 then
      return nil
    end
    return priority2 < priority1
  end
end

local private_label_comparator = function(entry1, entry2)
  local label_1 = entry1.completion_item.label
  local label_2 = entry2.completion_item.label

  -- Sort builtin python private entries last
  if string.sub(label_1, 1, 2) == '__' then
    if string.sub(label_2, 1, 2) == '__' then
      return nil
    end
    return false
  elseif string.sub(label_2, 1, 2) == '__' then
    return true
  end

  -- Sort private python entries last
  if string.sub(label_1, 1, 1) == '_' then
    if string.sub(label_2, 1, 1) == '_' then
      return nil
    end
    return false
  elseif string.sub(label_2, 1, 1) == '_' then
    return true
  end

  return nil
end

local label_comparator = function(entry1, entry2)
  return entry1.completion_item.label < entry2.completion_item.label
end

---- /Comparators ----


-- Default sources are buffers are always enabled.
-- Some sources are too slow on large files and are only enabled
-- depending on the file size.
local default_cmp_sources = cmp.config.sources({
  { name = 'copilot' },
  { name = 'nvim_lsp' },
  { name = 'snippy' },
}, {
  { name = 'buffer' }
})

-- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disable--enable-cmp-sources-only-on-certain-buffers
local bufIsBig = function(bufnr)
  local max_filesize = 100 * 1024 -- 100 KB
  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
  if ok and stats and stats.size > max_filesize then
    return true
  else
    return false
  end
end

local add_expensive_cmp_sources = function(t)
  local unpack = unpack or table.unpack
  local sources = {unpack(default_cmp_sources)}
  if not bufIsBig(t.buf) then
    sources[#sources + 1] = { name = 'buffer' }
  end
  cmp.setup.buffer { sources = sources }
end

-- vim.api.nvim_create_autocmd('BufReadPre', {callback = add_expensive_cmp_sources})


cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      snippy.expand_snippet(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = false }),

    -- ["."] = comp.mapping.complete(),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif snippy.can_expand_or_advance() then
        snippy.expand_or_advance()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif snippy.can_jump(-1) then
        snippy.previous()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = default_cmp_sources,
  completion = {
    -- default keyword_length needed for completion.
    -- can also be configured per source
    keyword_length = 2,
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
    }),
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.exact,
      require('copilot_cmp.comparators').prioritize,
      cmp.config.compare.offset,
      cmp.config.compare.recently_used,
      cmp.config.compare.length,
      -- cmp.config.compare.score,
      -- cmp.config.compare.scopes, -- prefer locals to globals
      lspkind_comparator({
        kind_priority = {
          Field = 11,
          Property = 11,
          Constant = 10,
          Enum = 10,
          EnumMember = 10,
          Event = 10,
          Function = 10,
          Method = 10,
          Operator = 10,
          Reference = 10,
          Struct = 10,
          Variable = 9,
          Class = 5,
          Module = 5,
          Keyword = 2,
          Interface = 1,
          Constructor = 1,
          Snippet = 1,
          Color = 1,
          File = 1,
          Folder = 1,
          Value = 1,
          Unit = 1,
          TypeParameter = 1,
          Text = 0,
          Operator = 1,
        },
      }),
      private_label_comparator,
      label_comparator,
    }
  },
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
-- do not enable buffer if file is too big.

local restricted_buffer_source = {
  name = 'buffer',
  option = { keyword_length = 2 },
  get_bufnrs = function()
    local buf = vim.api.nvim_get_current_buf()
    local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
    if byte_size > 1024 * 100 then -- 100KB max
      return {}
    end
    return { buf }
  end
}

--[[
vim.api.nvim_create_autocmd('BufReadPre', {
  callback = function(t)
    if not bufIsBig(t.buf) then
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { restricted_buffer_source }
      })
    end
  end
})
--]]

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { restricted_buffer_source },
  sorting = {
    comparators = {
      cmp.config.compare.exact,
      cmp.config.compare.length,
      label_comparator
    }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  sorting = {
    comparators = {
      cmp.config.compare.exact,
      cmp.config.compare.length,
      label_comparator
    }
  }
})

-- color the items in the menu by category
-- gray
vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { bg='NONE', strikethrough=true, fg='#808080' })
-- blue
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { bg='NONE', fg='#569CD6' })
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link='CmpIntemAbbrMatch' })
-- light blue
vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { bg='NONE', fg='#9CDCFE' })
vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { link='CmpItemKindVariable' })
vim.api.nvim_set_hl(0, 'CmpItemKindText', { link='CmpItemKindVariable' })
-- pink
vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { bg='NONE', fg='#C586C0' })
vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { link='CmpItemKindFunction' })
-- front
vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { bg='NONE', fg='#D4D4D4' })
vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { link='CmpItemKindKeyword' })
vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { link='CmpItemKindKeyword' })

-- Set up lspconfig.
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['pyright'].setup {
--   capabilities = capabilities
-- }
