local M = {}

local function set_lsp_hover_highlights()
  local normal_float = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
  local float_border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
  local float_title = vim.api.nvim_get_hl(0, { name = "FloatTitle", link = false })
  local visual = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
  local diagnostic_info = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo", link = false })

  local hover_bg = visual.bg or normal_float.bg

  vim.api.nvim_set_hl(0, "LspHoverNormal", vim.tbl_extend("force", normal_float, {
    bg = hover_bg,
  }))
  vim.api.nvim_set_hl(0, "LspHoverBorder", vim.tbl_extend("force", float_border, {
    fg = diagnostic_info.fg or float_border.fg,
    bg = hover_bg,
  }))
  vim.api.nvim_set_hl(0, "LspHoverTitle", vim.tbl_extend("force", float_title, {
    bg = hover_bg,
  }))
end

function M.setup()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("HonorFloatHighlights", { clear = true }),
    pattern = "*",
    callback = set_lsp_hover_highlights,
  })

  set_lsp_hover_highlights()
end

return M
