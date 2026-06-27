local M = {}

function M.setup()
  vim.g.neoterm_autoscroll = 1
  vim.g.neoterm_default_mod = "belowright"
  vim.g.neoterm_keep_term_open = 0

  vim.g["test#python#runner"] = "pytest"
  vim.g["test#python#pytest#file_pattern"] = [[\v(^|[\b_\.-])[Tt]est.*\.py$]]
  vim.g["test#strategy"] = "neoterm"

  vim.g["test#custom_transformations"] = {
    honor = function(cmd)
      if cmd:match("^(poetry|pipenv|uv) run pytest") then
        local cmd_sans_pytest = "-s " .. cmd:gsub("^(poetry|pipenv|uv) run pytest ", "")
        return "make singletest PARALLELISM=1 PYTESTARGS=" .. vim.fn.shellescape(cmd_sans_pytest)
      end
      return cmd
    end,
  }
  vim.g["test#transformation"] = "honor"

  vim.keymap.set("n", "<leader>tn", "<cmd>TestNearest -vv<CR>", { desc = "Run nearest test" })
  vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<CR>", { desc = "Run test file" })
  vim.keymap.set("n", "<leader>ts", "<cmd>TestSuite<CR>", { desc = "Run test suite" })
  vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<CR>", { desc = "Run last test" })
end

return M
