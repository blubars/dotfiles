return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codecompanion").setup({
        interactions = {
          chat = {
            adapter = "piacp",
          },
          inline = {
            adapter = "openai",
            model = "gpt-5.4-mini",
          },
          cli = {
            agent = "hagent",
            agents = {
              hagent = {
                cmd = "/Users/brianlubars/.local/share/mise/installs/node/24/bin/hagent",
                args = { "--profile", "b" },
                description = "Honor Agent CLI",
                provider = "terminal",
              },
            },
          },
        },
        adapters = {
          acp = {
            piacp = function()
              local helpers = require("codecompanion.adapters.acp.helpers")
              return {
                name = "pi-acp",
                formatted_name = "Honor Agent",
                type = "acp",
                commands = {
                  default = { "pi-acp" },
                },
                defaults = {
                  mcpServers = {},
                  timeout = 20000,
                },
                roles = {
                  llm = "assistant",
                  user = "user",
                },
                parameters = {
                  protocolVersion = 1,
                  clientCapabilities = {
                    fs = { readTextFile = true, writeTextFile = true },
                  },
                  clientInfo = {
                    name = "CodeCompanion.nvim",
                    version = "1.0.0",
                  },
                },
                handlers = {
                  setup = function()
                    return true
                  end,
                  auth = function()
                    return true
                  end,
                  form_messages = function(self, messages, capabilities)
                    return helpers.form_messages(self, messages, capabilities)
                  end,
                  on_exit = function() end,
                },
              }
            end,
          },
          opts = {
            show_presets = false,
          },
        },
        opts = {
          log_level = "DEBUG",
        },
      })

      vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.keymap.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
      vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    ft = { "markdown", "Avante" },
  },
}
