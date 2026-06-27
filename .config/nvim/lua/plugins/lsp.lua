return {
  {
    "lukas-reineke/lsp-format.nvim",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      require("config.lsp").setup()
    end,
  }
  -- "nvim-lua/plenary.nvim",
}
