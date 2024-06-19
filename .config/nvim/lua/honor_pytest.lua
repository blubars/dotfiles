-- wrapper around honor_pytest-pytest
local honor_pytest = {}

local async = require("neotest.async")
local lib = require("neotest.lib")
-- local neotest_python = require("neotest-python")

---@class honor_pytest.Adapter
---@field name string

local get_python = function(root)
  if not root then
    root = vim.loop.cwd()
  end
  return require('neotest-python.base').get_python_command(root)
end

local get_args = function()
  return {}
end

local get_runner = function(python_cmd)
  return 'pytest'
end

local function get_script()
  local paths = vim.api.nvim_get_runtime_file("neotest.py", true)
  for _, path in ipairs(paths) do
    if vim.endswith(path, ("neotest-python%sneotest.py"):format(lib.files.sep)) then
      return path
    end
  end

  error("neotest.py not found")
end

local function get_strategy_config(strategy, python, program, args)
  local config = {
    dap = function()
      return vim.tbl_extend("keep", {
        type = "python",
        name = "Neotest Debugger",
        request = "launch",
        python = python,
        program = program,
        cwd = async.fn.getcwd(),
        args = args,
      }, dap_args or {})
    end,
  }
  if config[strategy] then
    return config[strategy]()
  end
end

-- the neotest_python interface is a little funny: need to call the
-- adapter object to set the metadatable
neotest_python = require("neotest-python")
honor_pytest.Adapter = neotest_python({
  python = get_python,
  get_runner = get_runner
})
local adapter = honor_pytest.Adapter


print('adapter: ' .. vim.inspect(adapter))

---@async
---@param args neotest.RunArgs
---@return neotest.RunSpec
adapter.build_spec = function(args)
  local position = args.tree:data()
  local results_path = async.fn.tempname()
  local stream_path = async.fn.tempname()
  lib.files.write(stream_path, "")

  local root = honor_pytest.Adapter.root(position.path)
  local python = get_python(root)
  -- local runner = adapter.get_runner(python)
  local runner = get_runner(python)
  local stream_data, stop_stream = lib.files.stream_lines(stream_path)
  local script_args = vim.tbl_flatten({
    "--results-file",
    results_path,
    "--stream-file",
    stream_path,
    "--runner",
    runner,
    "--",
    vim.list_extend(get_args(runner, position), args.extra_args or {}),
  })
  if position then
    table.insert(script_args, position.id)
  end
  local python_script = get_script()
  local command = vim.tbl_flatten({
    python,
    python_script,
    script_args,
  })
  local strategy_config = get_strategy_config(args.strategy, python, python_script, script_args)
  ---@type neotest.RunSpec
  print('cmd: ' .. vim.inspect(command))
  return {
    command = command,
    context = {
      results_path = results_path,
      stop_stream = stop_stream,
    },
    stream = function()
      return function()
        local lines = stream_data()
        local results = {}
        for _, line in ipairs(lines) do
          local result = vim.json.decode(line, { luanil = { object = true } })
          results[result.id] = result.result
        end
        return results
      end
    end,
    strategy = strategy_config,
  }
end

--[[

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function honor_pytest.Adapter.root(dir) end

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project
---@return boolean
function honor_pytest.Adapter.filter_dir(name, rel_path, root) end

---@async
---@param file_path string
---@return boolean
function honor_pytest.Adapter.is_test_file(file_path) end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return honor_pytest.Tree | nil
function honor_pytest.Adapter.discover_positions(file_path) end

---@param args honor_pytest.RunArgs
---@return nil | honor_pytest.RunSpec | neotest.RunSpec[]
function honor_pytest.Adapter.build_spec(args) end

---@async
---@param spec honor_pytest.RunSpec
---@param result honor_pytest.StrategyResult
---@param tree honor_pytest.Tree
---@return table<string, honor_pytest.Result>
function honor_pytest.Adapter.results(spec, result, tree) end
--]]
return honor_pytest
