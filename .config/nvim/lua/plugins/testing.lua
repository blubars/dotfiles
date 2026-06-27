return {
  {
    "kassio/neoterm",
    cmd = { "T", "Tnew", "Topen", "Tclose" },
  },
  {
    "janko/vim-test",
    dependencies = { "kassio/neoterm" },
    config = function()
      require("config.vim_test").setup()
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      require("config.testing").setup()
    end,
  },
}
