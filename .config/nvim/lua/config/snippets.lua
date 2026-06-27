local M = {}

function M.setup()
  local snippy = require("snippy")

  snippy.setup({
    mappings = {
      i = {
        ["<C-u>"] = "expand_or_advance",
        ["<C-i>"] = "previous",
      },
    },
  })

  vim.keymap.set("i", "<C-s>", function()
    snippy.complete()
  end, { desc = "Snippy complete" })
end

return M
