local M = {}

function M.setup()
  vim.api.nvim_create_user_command("Grep", function(opts)
    vim.cmd("silent grep! " .. opts.args)
    vim.cmd("copen")
    pcall(vim.cmd, "/" .. opts.args .. "\\c")
  end, { nargs = "+", complete = "file" })

  vim.api.nvim_create_user_command("NewReactComponent", function(opts)
    local component_name = opts.fargs[1]
    local current_dir = vim.fn.expand("%:h")

    vim.cmd(string.format("silent !yarn generate react %s %s", current_dir, component_name))
    vim.cmd("split " .. vim.fn.fnameescape(current_dir .. "/" .. component_name))
  end, { nargs = 1, force = true })
end

return M
