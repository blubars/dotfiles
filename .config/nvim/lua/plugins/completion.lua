return {
  {
    "dcampos/nvim-snippy",
    event = "InsertEnter",
    config = function()
      require("config.snippets").setup()
    end,
  },
  { "honza/vim-snippets", lazy = true },
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-path",
      "dcampos/cmp-snippy",
      "onsails/lspkind.nvim",
      {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
          check_ts = true,
        },
      },
    },
    config = function()
      require("config.completion").setup()
    end,
  },
}
