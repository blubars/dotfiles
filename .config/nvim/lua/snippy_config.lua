local snippy = require("snippy")

snippy.setup({
  mappings = {
    i = {
      ["<C-u>"] = "expand_or_advance",
      ["<C-i>"] = "previous",
    },
  },
})

-- Insert mode snippy completion mapping - '<Control-s>'
vim.keymap.set("i", "<C-s>", function()
  snippy.complete()
end) --, { silent = true })
