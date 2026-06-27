local opt = vim.opt
local g = vim.g

opt.swapfile = false
opt.shell = "/bin/zsh"
opt.mouse = "a"
opt.modeline = true
opt.backspace = { "indent", "eol", "start" }
opt.number = true
opt.title = true
opt.titlestring = "nvim - %t"
opt.background = "dark"

--------------------------------------------------------------------------------
--- SPACING / WRAP
--------------------------------------------------------------------------------
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.list = true  -- show whitespace as chars (excl space)
opt.listchars = { tab = ">-", trail = "-" }

-- default: tcqj
-- t = auto-wrap text using tw
-- c = auto-wrap comments
-- q = allow formatting of comments with "gq"
-- n = recognize numbered lists
opt.formatoptions = "cqj"
opt.textwidth = 100  -- autowrap. Use "gq" to reformat (or "gw<movement>")

--------------------------------------------------------------------------------
--- FOLDS
--------------------------------------------------------------------------------
opt.foldmethod = "indent"
opt.foldlevel = 3
opt.hlsearch = true

--------------------------------------------------------------------------------
--- OTHER
--------------------------------------------------------------------------------
opt.grepprg = table.concat({
  "rg",
  "--vimgrep",
  "-i",
  "-T",
  "json",
  "-g",
  vim.fn.shellescape("!tags"),
  "-g",
  vim.fn.shellescape("!.mypy_cache/**"),
  "-g",
  vim.fn.shellescape("!.direnv/**"),
  "-g",
  vim.fn.shellescape("!node_modules/**"),
  "-g",
  vim.fn.shellescape("!.pytest_cache/**"),
}, " ")

-- Python provider for pynvim-based plugins.
g.python3_host_prog = "/Users/brianlubars/.pyenv/versions/3.8.10/envs/venv-nvim/bin/python3"
g.python_host_prog = "/Users/brianlubars/.pyenv/versions/3.8.10/envs/venv-nvim/bin/python"
g.sls_use_jinja_syntax = 1
