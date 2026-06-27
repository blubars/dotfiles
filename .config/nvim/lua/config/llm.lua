local M = {}

local highlight_ns = vim.api.nvim_create_namespace("LlmExplainHighlight")

local function open_window(title)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

  local width = vim.api.nvim_get_option_value("columns", {})
  local height = vim.api.nvim_get_option_value("lines", {})
  local win_height = math.ceil(height * 0.7 - 4)
  local win_width = math.ceil(width * 0.5)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) * 0.9)

  local win = vim.api.nvim_open_win(buf, true, {
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
  })

  vim.api.nvim_set_option_value("textwidth", win_width, { buf = buf })
  return buf, win
end

local function set_close_mapping(win, buf, orig_buf, job_id)
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    vim.api.nvim_buf_clear_namespace(orig_buf, highlight_ns, 0, -1)
    if job_id then
      vim.fn.jobstop(job_id)
    end
  end, { buffer = buf, silent = true })
end

local function selected_lines(command)
  local buf = vim.api.nvim_win_get_buf(0)
  local start_line = command.line1 - 1 or 0
  local end_line = command.line2 or -1
  local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)
  return buf, start_line, end_line, lines
end

local function stream_to_float(title, prompt, command, on_exit)
  local orig_buf, start_line, end_line, lines = selected_lines(command)
  for line = start_line, end_line do
    vim.api.nvim_buf_add_highlight(orig_buf, highlight_ns, "Visual", line, 0, -1)
  end

  local buf, win = open_window(title)
  local function write_to_buf(_, data)
    if data and #data > 0 then
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
    end
  end

  local job_id = vim.fn.jobstart({ "llm", "-s", prompt }, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = write_to_buf,
    on_stderr = write_to_buf,
    on_exit = function(...)
      if on_exit then
        on_exit(buf, win, ...)
      end
    end,
  })

  vim.fn.chansend(job_id, lines)
  vim.fn.chanclose(job_id, "stdin")
  set_close_mapping(win, buf, orig_buf, job_id)
end

local function replace_selection(prompt, command)
  local buf, start_line, end_line, lines = selected_lines(command)
  vim.api.nvim_buf_set_lines(buf, start_line, end_line, false, {})
  local line_count = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_win_set_cursor(0, { math.min(start_line + 1, line_count), 0 })

  local job_id = vim.fn.jobstart({ "llm", "-s", prompt }, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if data and #data > 0 then
        vim.api.nvim_put(data, "c", true, true)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.notify(table.concat(data, "\n"), vim.log.levels.WARN)
      end
    end,
  })

  vim.fn.chansend(job_id, lines)
  vim.fn.chanclose(job_id, "stdin")
  vim.keymap.set("n", "q", function()
    vim.fn.jobstop(job_id)
  end, { buffer = buf, silent = true })
end

function M.setup()
  vim.api.nvim_create_user_command("LlmExplain", function(command)
    local filetype = vim.bo.filetype
    stream_to_float("LLM output: explain", "Briefly explain the following " .. filetype .. " code", command, function(buf, win)
      vim.cmd("normal! gggqG")
      local line_count = vim.api.nvim_buf_line_count(buf)
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_height(win, line_count)
      end
    end)
  end, { range = "%" })

  vim.api.nvim_create_user_command("LlmReview", function(command)
    local filetype = vim.bo.filetype
    stream_to_float(
      "LLM output: review",
      "Briefly review the following " .. filetype .. " code. Be sure to point out any major code smells or bugs, and make recommendations to improve clarity. Do not make nitpicky comments or make up issues. If there are no issues or recommendations, say LGTM!",
      command,
      function(buf, win)
        local line_count = vim.api.nvim_buf_line_count(buf)
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_set_height(win, line_count)
        end
      end
    )
  end, { range = "%" })

  vim.api.nvim_create_user_command("LlmFix", function(command)
    local filetype = vim.bo.filetype
    replace_selection(
      "Review the following " .. filetype .. " code. If you find any bugs or code smells, update the code to fix them. Do not make unnecessary changes and do not change any functional aspects of the code. Your response should be the updated file with only the valid code, and no other text",
      command
    )
  end, { range = "%" })

  vim.api.nvim_create_user_command("LlmAddTypes", function(command)
    local filetype = vim.bo.filetype
    replace_selection(
      "Update the following " .. filetype .. " code to add type annotations. Do not make unnecessary changes and do not change any functional aspects of the code. Your response should be the updated file with only the valid code as a functional python file, with no markdown or other text.",
      command
    )
  end, { range = "%" })
end

return M
