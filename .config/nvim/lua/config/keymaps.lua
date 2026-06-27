local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Window navigation from normal/insert/terminal modes.
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("i", "<C-h>", "<C-\\><C-n><C-w>h")
map("i", "<C-j>", "<C-\\><C-n><C-w>j")
map("i", "<C-k>", "<C-\\><C-n><C-w>k")
map("i", "<C-l>", "<C-\\><C-n><C-w>l")
map("t", "<C-h>", "<C-\\><C-n><C-w>h")
map("t", "<C-j>", "<C-\\><C-n><C-w>j")
map("t", "<C-k>", "<C-\\><C-n><C-w>k")
map("t", "<C-l>", "<C-\\><C-n><C-w>l")

map("n", "<leader>g", function()
  vim.cmd("Grep " .. vim.fn.expand("<cword>"))
end, { desc = "Grep word under cursor" })

map("n", "<leader>T", "<cmd>!ctags --exclude='*.json' --exclude='\\.+*' --exclude='*thrift' --exclude='*.sql' -R .<CR>", { desc = "Generate ctags" })
map("n", "<leader>p", ":", { desc = "Command-line substitute helper" })
map("n", "<Space><Space>", function()
  if vim.fn.foldlevel(".") > 0 then
    vim.cmd("normal! za")
  else
    vim.api.nvim_feedkeys(" ", "n", false)
  end
end, { silent = true, desc = "Toggle fold" })
map("i", "<C-Space>", "<C-X><C-N>")
map("n", "<leader>r", function()
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Reloaded init.lua")
end, { desc = "Reload config" })
