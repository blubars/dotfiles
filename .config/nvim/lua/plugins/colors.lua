return {
  {
    "ellisonleao/gruvbox.nvim",
    -- make sure to load this before all the other start plugins
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = false,
          emphasis = true,
          comments = true,
          operators = false,
          folds = false,
        },
        invert_selection = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "hard",
        palette_overrides = {},
        overrides = {
          Whitespace = { fg = "#fbf1c7", bg = "#fb4934" },
          FloatBorder = { fg = "#7c6f64", bg = "NONE" },
          TreesitterContextBottom = { underline = true, sp = "#7c6f64" },
        },
        transparent_mode = false,
      })
    end,
  },
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("everforest")
    end,
  },
  {
    "sainnhe/sonokai",
    lazy = false,
    enabled = true,
    priority = 1000,
    config = function()
      vim.g.sonokai_style = 'espresso'
      vim.g.sonokai_disable_italic_comment = 1
      vim.g.sonokai_transparent_background = 0
    end,
  },
}
