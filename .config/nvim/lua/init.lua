require('cmp_config')
require('lsp')
require('snippy_config')
require('neotest_config')
require('llm')

require('copilot').setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
  -- TODO: make this runtime
  copilot_node_command = vim.fn.expand("$HOME") .. "/.asdf/installs/nodejs/20.19.0/bin/node"
})
require("copilot_cmp").setup()

-- require('nvim-treesitter.configs').setup {
--   -- Automatically install missing parsers when entering buffer
--   -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
--   auto_install = true,
-- 
--   -- docs say this is experimental
--   indent = {enable = true},
-- 
--   highlight = {
--     enable = true,
--     -- Disable slow treesitter highlight for large files
--     disable = function(lang, buf)
--       local max_filesize = 100 * 1024 -- 100 KB
--       local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
--       if ok and stats and stats.size > max_filesize then
--         return true
--       end
--     end,
--     -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
--     -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
--     -- Using this option may slow down your editor, and you may see some duplicate highlights.
--     -- Instead of true it can also be a list of languages
--     additional_vim_regex_highlighting = false,
--   },
-- }

-- require('treesitter-context').setup({
--   enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
--   max_lines = 2, -- How many lines the window should span. Values <= 0 mean no limit.
--   min_window_height = 40, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
--   line_numbers = true,
--   multiline_threshold = 1, -- Maximum number of lines to show for a single context
--   trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
--   mode = 'topline',  -- Line used to calculate context. Choices: 'cursor', 'topline'
--   -- Separator between context and content. Should be a single character string, like '-'.
--   -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
--   -- separator = nil,
--   -- zindex = 20, -- The Z-index of the context window
--   -- on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
-- })
