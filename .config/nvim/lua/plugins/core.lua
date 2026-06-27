return {
  { "tpope/vim-surround", event = "VeryLazy" },
  { "tpope/vim-rhubarb", event = "VeryLazy" },
  { "tpope/vim-fugitive", cmd = { "Git", "G", "GBrowse" } },
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        -- theme = "gruvbox",
        theme = "everforest",
        globalstatus = false,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            "filename",
            path = 1,
            symbols = {
              modified = " [+]",
              readonly = " [RO]",
              unnamed = "[No Name]",
              newfile = " [New]",
            },
          },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            "filename",
            path = 1,
            symbols = {
              modified = " [+]",
              readonly = " [RO]",
              unnamed = "[No Name]",
              newfile = " [New]",
            },
          },
        },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        default_direction = "prefer_left",
        min_width = 28,
      },
      attach_mode = "window",
      show_guides = true,
    },
    init = function()
      vim.keymap.set("n", "<leader>d", "<cmd>AerialToggle<CR>", { desc = "Toggle symbols outline" })
    end,
  },
  { "saltstack/salt-vim", ft = { "sls" } },
  { "Glench/Vim-Jinja2-Syntax", ft = { "jinja", "jinja2" } },
}
