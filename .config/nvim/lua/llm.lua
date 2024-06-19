local hi_ns_id = vim.api.nvim_create_namespace('LlmExplainHighlight')

-- Center a line of text
local function center(str)
  local width = vim.api.nvim_win_get_width(0)
  local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
  return string.rep(' ', shift) .. str
end

-- based on: https://dev.to/2nit/how-to-write-neovim-plugins-in-lua-5cca
local function open_window(title)
  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('bufhidden', 'wipe', {buf = buf})
  -- get dimensions
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")
  -- calculate our floating window size
  local win_height = math.ceil(height * 0.7 - 4)
  local win_width = math.ceil(width * 0.5)
  -- and its starting position
  local row = math.ceil((height - win_height) / 2 - 1)
  -- local col = math.ceil((width - win_width) / 2)
  -- push to the left
  local col = math.ceil((width - win_width) * 0.9)
  local opts = {
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }

  -- and finally create it with buffer attached
  win = vim.api.nvim_open_win(buf, true, opts)
  -- set us up to reformat with the correct window width later.
  vim.api.nvim_set_option_value('textwidth', win_width, {buf = buf})

  -- local underline = '-'
  -- repeat
  --   underline = underline..'-'
  -- until #underline == #title

  -- vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
  --   center(title), center(underline), ''
  -- })
  return buf, win
end

local function set_mappings(win, buf, orig_buf, job_id)
  local function close_window()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_clear_namespace(orig_buf, hi_ns_id, 0, -1)
    -- In case the job is still running, kill it
    vim.fn.jobstop(job_id)
  end

  local mappings = {
    q = close_window,
  }

  for k,v in pairs(mappings) do
    vim.api.nvim_buf_set_keymap(buf, 'n', k, '', {
        nowait = true,
        noremap = true,
        silent = true,
        callback = v,
      })
  end
end

local function join(strings, delim)
  local result = ''
  for _,v in ipairs(strings) do
    if #result == 0 then
      result = v
    else
      result = result .. delim .. v
    end
  end
  return result
end

local function explain(command)
  local code_buf = vim.api.nvim_win_get_buf(0)
  -- Indexing for `get_lines` is 0-based
  -- local lstart, lend = command.line1 - 1 or 0, command.line2 or -1
  local lstart, lend = command.line1 - 1 or 0, command.line2 or -1
  local lines = vim.api.nvim_buf_get_lines(code_buf, lstart, lend, false)
  -- highlight the selected lines
  for i = lstart, lend do
    vim.api.nvim_buf_add_highlight(code_buf, hi_ns_id, 'Visual', i, 0, -1)
  end

  -- Create the window and buffer
  local buf, win = open_window('LLM output: explain')

  local function write_to_buf(job_id, data, event)
    -- vim.print(data)
    -- vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
    vim.api.nvim_put(data, 'c', true, true)
  end

  local function resize_window()
    vim.print('Job exited')
    -- vim.api.nvim_win_set_cursor(win, (1, 0))
    -- Reformat the text to fit the buffer window
    vim.cmd('normal gggqG')
    local line_count = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_height(win, line_count)
  end

  -- local text = join(lines, '/n')
  --
  -- local opts = {stdin = lines, text = true, timeout = 8}
  --vim.system({'llm', '-s', 'Explain this code'}, opts, onResult)

  -- use `jobstart` to spawn a call to the llm.
  local filetype = vim.bo.filetype
  local cmd = "llm -s 'Briefly explain the following " .. filetype .. " code'"
  local opts = {
    on_stdout = write_to_buf,
    on_stderr = write_to_buf,
    on_exit = resize_window,
  }
  local job_id = vim.fn.jobstart(cmd, opts)
  vim.fn.chansend(job_id, lines)
  vim.fn.chanclose(job_id, 'stdin')

  set_mappings(win, buf, code_buf, job_id)

  -- local result = vim.fn.systemlist(cmd, lines)
  -- onResult({code = vim.v.shell_error, stdout = result, stderr = 'Error'})
  --local result = vim.system("'<,'>:w !" .. cmd)
  -- vim.api.nvim_buf_set_lines(0, 3, 3, false, system)
end

local function review(command)
  local code_buf = vim.api.nvim_win_get_buf(0)
  local lstart, lend = command.line1 - 1 or 0, command.line2 or -1
  local lines = vim.api.nvim_buf_get_lines(code_buf, lstart, lend, false)

  -- Create the window and buffer
  local buf, win = open_window('LLM output: review')

  local function write_to_buf(job_id, data, event)
    -- vim.print(data)
    -- vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
    vim.api.nvim_put(data, 'c', true, true)
  end

  local function resize_window()
    vim.print('Job exited')
    local line_count = vim.api.nvim_buf_line_count(buf)
    vim.print(line_count)
    vim.api.nvim_win_set_height(win, line_count)
  end

  local filetype = vim.bo.filetype
  local cmd = "llm -s 'Briefly review the following " .. filetype .. " code. Be sure to point out any major code smells or bugs, and make recommendations to improve clarity. Do not make nitpicky comments or make up issues. If there are no issues or recommendations, say LGTM!'"
  local opts = {
    on_stdout = write_to_buf,
    on_stderr = write_to_buf,
    on_exit = resize_window,
  }
  local job_id = vim.fn.jobstart(cmd, opts)
  vim.fn.chansend(job_id, lines)
  vim.fn.chanclose(job_id, 'stdin')

  set_mappings(win, buf, code_buf, job_id)

  -- local result = vim.fn.systemlist(cmd, lines)
  -- onResult({code = vim.v.shell_error, stdout = result, stderr = 'Error'})
  --local result = vim.system("'<,'>:w !" .. cmd)
  -- vim.api.nvim_buf_set_lines(0, 3, 3, false, system)
end

local function fix(command)
  local buf = vim.api.nvim_win_get_buf(0)
  local lstart, lend = command.line1 - 1 or 0, command.line2 or -1
  local lines = vim.api.nvim_buf_get_lines(buf, lstart, lend, false)

  -- clear the existing lines. Then replace with LLM output
  vim.print({buf, lstart, lend})
  vim.api.nvim_buf_set_lines(buf, lstart, lend, false, {})
  -- 1-indexed row
  vim.api.nvim_win_set_cursor(0, {lstart + 1, 0})

  local function write_to_buf(job_id, data, event)
    -- vim.print(data)
    -- vim.api.nvim_buf_set_lines(buf, lstart, lstart, false, data)
    vim.api.nvim_put(data, 'c', true, true)
  end

  local filetype = vim.bo.filetype
  local cmd = "llm -s 'Review the following " .. filetype .. " code. If you find any bugs or code smells, update the code to fix them. Do not make unnecessary changes and do not change any functional aspects of the code. Your response should be the updated file with only the valid code, and no other text'"

  local opts = {
    on_stdout = write_to_buf,
    on_stderr = write_to_buf,
  }
  local job_id = vim.fn.jobstart(cmd, opts)
  vim.fn.chansend(job_id, lines)
  vim.fn.chanclose(job_id, 'stdin')

  local function cancel()
    vim.fn.jobstop(job_id)
  end

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = cancel,
  })

  -- TODO: save into temp buffer, then use git to diff
end

local function add_types(command)
  local buf = vim.api.nvim_win_get_buf(0)
  local lstart, lend = command.line1 - 1 or 0, command.line2 or -1
  local lines = vim.api.nvim_buf_get_lines(buf, lstart, lend, false)

  -- clear the existing lines. Then replace with LLM output
  vim.print({buf, lstart, lend})
  vim.api.nvim_buf_set_lines(buf, lstart, lend, false, {})

  local line_count = vim.api.nvim_buf_line_count(buf)
  -- 1-indexed row
  vim.api.nvim_win_set_cursor(0, {math.min(lstart + 1, line_count), 0})

  local function write_to_buf(job_id, data, event)
    -- vim.print(data)
    -- vim.api.nvim_buf_set_lines(buf, lstart, lstart, false, data)
    vim.api.nvim_put(data, 'c', true, true)
  end

  local filetype = vim.bo.filetype
  local cmd = "llm -s 'Update the following " .. filetype .. " code to add type annotations. Do not make unnecessary changes and do not change any functional aspects of the code. Your response should be the updated file with only the valid code as a functional python file, with no markdown or other text.'"

  local opts = {
    on_stdout = write_to_buf,
    on_stderr = write_to_buf,
  }
  local job_id = vim.fn.jobstart(cmd, opts)
  vim.fn.chansend(job_id, lines)
  vim.fn.chanclose(job_id, 'stdin')

  local function cancel()
    vim.fn.jobstop(job_id)
  end

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = cancel,
  })

  -- TODO: save into temp buffer, then use git to diff
end

vim.api.nvim_create_user_command('LlmExplain', explain, {range = '%'})
vim.api.nvim_create_user_command('LlmReview', review, {range = '%'})
vim.api.nvim_create_user_command('LlmFix', fix, {range = '%'})
vim.api.nvim_create_user_command('LlmAddTypes', add_types, {range = '%'})

return {
  explain = explain,
  review = review,
  fix = fix,
  close_window = close_window,
}
