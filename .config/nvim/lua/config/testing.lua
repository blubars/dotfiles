local M = {}

function M.setup()
  local neotest = require("neotest")
  local neotest_python = require("neotest-python")

  local function get_runner()
    return "honor_pytest"
  end

  local function get_args()
    return {
      "--numprocesses=1",
      "--disable-warnings",
      "-s",
    }
  end

  neotest.setup({
    adapters = {
      neotest_python({
        args = get_args,
        runner = get_runner,
      }),
    },
    quickfix = {
      enabled = true,
      open = true,
    },
  })

  vim.api.nvim_create_user_command("Tst", function(opts)
    if opts.args ~= "" then
      neotest.run.run(opts.args)
    else
      neotest.run.run()
    end
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("TstN", function()
    neotest.run.run()
  end, { nargs = 0 })

  vim.api.nvim_create_user_command("TstS", function()
    neotest.output.open({ enter = true, auto_close = true })
  end, { nargs = 0 })

  vim.api.nvim_create_user_command("TstD", neotest.output_panel.toggle, { nargs = 0 })
  vim.api.nvim_create_user_command("TstC", neotest.output_panel.clear, { nargs = 0 })
  vim.api.nvim_create_user_command("TstW", function()
    neotest.watch.toggle(vim.fn.expand("%"))
    vim.cmd("copen")
    vim.cmd("wincmd p")
  end, { nargs = 0 })
  vim.api.nvim_create_user_command("TstSum", neotest.summary.toggle, { nargs = 0 })
  vim.api.nvim_create_user_command("TstF", function()
    neotest.run.run(vim.fn.expand("%"))
  end, { nargs = 0 })

  local function jump_to_error(fn)
    return function()
      fn({ status = "failed" })
    end
  end

  vim.keymap.set("n", "<localleader>tw", "<cmd>TstW<CR>", { desc = "Watch file tests" })
  vim.keymap.set("n", "<localleader>to", "<cmd>TstS<CR>", { desc = "Open test output" })
  vim.keymap.set("n", "<localleader>tq", neotest.run.stop, { desc = "Stop test run" })
  vim.keymap.set("n", "<localleader>t[", jump_to_error(neotest.jump.prev), { desc = "Prev failed test" })
  vim.keymap.set("n", "<localleader>t]", jump_to_error(neotest.jump.next), { desc = "Next failed test" })
end

return M
