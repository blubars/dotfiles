local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local indent_group = augroup("CfgIndent", { clear = true })
autocmd("FileType", {
  group = indent_group,
  pattern = { "vim", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

local gitcommit_group = augroup("CfgGitCommit", { clear = true })
autocmd("FileType", {
  group = gitcommit_group,
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.spell = true
  end,
})

local terminal_group = augroup("CfgTerminal", { clear = true })
autocmd("TermOpen", {
  group = terminal_group,
  pattern = "*",
  callback = function(args)
    vim.keymap.set("n", "<CR>", "G$i", { buffer = args.buf })
  end,
})

-- Delete fugitive buffers when hidden
local fugitive_group = augroup("CfgFugitive", { clear = true })
autocmd("BufReadPost", {
  group = fugitive_group,
  pattern = "fugitive://*",
  callback = function()
    vim.opt_local.bufhidden = "delete"
  end,
})

local cursorline_group = augroup("CfgCursorLine", { clear = true })
autocmd({ "WinEnter", "BufWinEnter" }, {
  group = cursorline_group,
  pattern = "*",
  callback = function()
    vim.opt_local.cursorline = true
  end,
})
autocmd("WinLeave", {
  group = cursorline_group,
  pattern = "*",
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

