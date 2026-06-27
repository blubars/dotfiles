local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local template_dir = vim.fn.stdpath("state") .. "/empty-git-template"

vim.fn.mkdir(template_dir, "p")
vim.env.GIT_TEMPLATE_DIR = template_dir

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "--template=" .. template_dir,
    repo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { result, "WarningMsg" },
    }, true, {})
    error("Failed to bootstrap lazy.nvim")
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
  },
  install = {
    colorscheme = { "gruvbox" },
  },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
