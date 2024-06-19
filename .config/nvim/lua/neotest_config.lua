--[[
local function honor_make_test_runner()
  local cmd_sans_pytest = "-s ".substitute(a:cmd, '^\(poetry\|pipenv\) run pytest ', '', '')
  local new_cmd = 'make singletest PARALLELISM=1 PYTESTARGS='.shellescape(l:cmd_sans_pytest)
end
--]]

local neotest = require("neotest")
local neotest_python = require("neotest-python")

-- local honor_pytest = require('honor_pytest')

local get_python = function(root)
  if not root then
    root = vim.loop.cwd()
  end
  return require('neotest-python.base').get_python_command(root)
end

local get_runner = function(python_cmd)
  return 'honor_pytest'
end

local get_args = function(runner, position)
  -- print('position: ' .. vim.inspect(position))

  -- TODO: pytest-xdist is not working with neotest-python
  -- https://github.com/pytest-dev/pytest-xdist/issues/681
  -- Try loading it dynamically into env and passing as an arg?
  -- https://docs.pytest.org/en/7.1.x/how-to/writing_plugins.html#making-your-plugin-installable-by-others
  return {
    '--numprocesses=1',
    '--disable-warnings',
    '-s',  -- do not run in parallel until xdist is working
  }
end


neotest.setup({
  adapters = {
    -- honor_pytest.Adapter,
    neotest_python({
        -- Extra arguments for nvim-dap configuration
        -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
        -- dap = { justMyCode = false },
        -- Command line arguments for runner
        -- Can also be a function to return dynamic values
        -- args = {"--log-level", "DEBUG"},
        args = get_args,
        -- Runner to use. Will use pytest if available by default.
        -- Can be a function to return dynamic value.
        runner = get_runner,
        -- Custom python path for the runner.
        -- Can be a string or a list of strings.
        -- Can also be a function to return dynamic value.
        -- If not provided, the path will be inferred by checking for
        -- virtual envs in the local directory and for Pipenev/Poetry configs
        -- python = ".venv/bin/python",
        --python = get_python,
    })
  },
  quickfix = {
    enabled = true,
    open = true,
  }
})

local open_qf_if_errors = function()
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
    vim.cmd("wincmd p")
  end
end


vim.api.nvim_create_user_command(
  'Tst',
  function(opts)
    if opts.nargs == 1 then
      neotest.run.run(opts.fargs[0])
    else
      neotest.run.run()
    end
  end,
  { nargs = '?' }
)
vim.api.nvim_create_user_command(
  'TstN',
  function()
    neotest.run.run()
  end,
  {nargs = 0}
)
vim.api.nvim_create_user_command(
  'TstS',
  function(opts)
    neotest.output.open({enter = true, auto_close = true})
  end,
  {nargs = 0}
)
vim.api.nvim_create_user_command('TstD', neotest.output_panel.toggle, {nargs=0})
vim.api.nvim_create_user_command('TstC', neotest.output_panel.clear, {nargs=0})
-- vim.api.nvim_create_user_command('TstQF', neotest.quickfix, {nargs=0})
-- toggle watching the current file
vim.api.nvim_create_user_command(
  'TstW',
  function()
    neotest.watch.toggle(vim.fn.expand("%"))
    vim.cmd("copen")
    vim.cmd("wincmd p")
  end,
  {nargs=0}
)
-- toggle showing a test summary
vim.api.nvim_create_user_command('TstSum', neotest.summary.toggle, {nargs=0})


vim.api.nvim_create_user_command(
  'TstF',
  function()
    -- run tests in file, open quickfix window, ump to 1st error
    neotest.run.run(vim.fn.expand("%"))
    -- open_qf_if_errors()
    -- neotest.jump.next({status = "failed"})
  end,
  {nargs = 0}
)

local jump_to_error = function(fn)
  return function()
    fn({status = "failed"})
  end
end


-- set up keymaps
vim.keymap.set('n', '<leader>tn', ':TstN<CR>')
vim.keymap.set('n', '<leader>tf', ':TstF<CR>')
vim.keymap.set('n', '<leader>tw', ':TstW<CR>')
vim.keymap.set('n', '<leader>ts', ':TstS<CR>')
vim.keymap.set('n', '<leader>tq', neotest.run.stop)
vim.keymap.set('n', '<leader>t[', jump_to_error(neotest.jump.prev))
vim.keymap.set('n', '<leader>t]', jump_to_error(neotest.jump.next))
