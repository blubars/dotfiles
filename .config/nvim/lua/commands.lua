vim.api.nvim_create_command('NewReactComponent',
  function(opts)
    local component_name = opts.fargs[1]
    vim.cmd(
      string.format(
        'silent !yarn generate react %s %s',
        vim.fn.expand('%:h'),
        component_name,
      )
    )
    vim.cmd(
      string.format('split %/%', vim.fn.expand('%:h'), component_name)
    )
  end,
  { nargs = 1, force = true }
)

vim.api.nvim_create_user_command('Upper',
  function(opts)
    print(string.upper(opts.fargs[1]))
  end,
  { nargs = 1 })
vim.cmd.Upper('foo')
--> FOO
