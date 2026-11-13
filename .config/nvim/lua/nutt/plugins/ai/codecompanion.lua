---@module "lazy"
---@type LazySpec
return {
  -- Code Companion
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = true,
    ---@module "codecompanion"
    opts = {
      interactions = {
        chat = {
          adapter = "opencode",
          roles = {
            ---The header name for the LLM's messages
            ---@type string|fun(adapter: unknown): string
            llm = function(adapter)
              local name = adapter.formatted_name

              local display_name = string.format("Clanker 󰚩 (%s)", name)

              return display_name
            end,
          },
          keymaps = {
            send = {
              modes = {
                n = "<CR>",
                i = "<CR>",
              },
              description = "Send the message over",
            },
            close = {
              modes = {
                n = "<leader>ad",
              },
              description = "Close chat buffer",
            },
            change_adapter = {
              modes = {
                n = "<leader>am",
              },
              description = "Change adapter and model",
            },
          },
          slash_commands = {
            resume = {
              keymaps = {
                modes = { n = "<leader>al" },
              },
            },
            acp_session_options = {
              keymaps = {
                modes = { n = "<leader>as" },
              },
            },
          },
          opts = {
            completion_provider = "blink",
          },
        },
      },
      adapters = {
        acp = {
          extend = {
            opencode = {
              defaults = {
                session_config_options = {
                  model = "opencode/claude-opus-5-5",
                  mode = "plan",
                },
              },
            },
          },
        },
      },
      display = {
        action_palette = {
          provider = "default",
        },
        chat = {
          window = {
            layout = "vertical",
            position = "left",
          },
          intro_message = "Start The Chat! Press ? for options",
          show_settings = false,
          show_token_count = true,
          show_context = true,
          show_reasoning = true,
        },
      },
    },
    keys = {
      {
        "<leader>aj",
        mode = { "n" },
        function()
          require("codecompanion").toggle()
        end,
        desc = "Open a new chat buffer",
      },
      {
        "<leader>ap",
        mode = { "n", "x" },
        function()
          require("codecompanion").actions({})
        end,
        desc = "AI Available Actions",
      },
      {
        "<leader>aj",
        mode = { "x" },
        "<cmd>CodeCompanionChat Add<cr>",
        desc = "Paste the selected into the latest AI Chat",
      },
    },
  },
  -- Add blink code completion
  ---@module "lazy"
  ---@type LazySpec
  {
    "Saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      },
    },
  },
  -- Lualine
  ---@module "lazy"
  ---@type LazySpec
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Extension
      local codecompanion = {
        sections = {
          lualine_a = {
            {
              function()
                return "󰚩 Code Companion"
              end,
              separator = {
                left = "",
                right = "",
              },
            },
          },
          lualine_y = {
            {
              function()
                local current = vim.api.nvim_get_current_buf()

                ---@type boolean
                local modifiable = vim.api.nvim_get_option_value("modifiable", { buf = current })
                local status = (not modifiable and "󰟶 Thinking...") or " Ask me anything"

                return status
              end,
            },
          },
          lualine_z = {
            {
              function()
                return " " .. os.date("%I:%M %p")
              end,
              separator = {
                left = "",
                right = "",
              },
            },
          },
        },
        filetypes = {
          "codecompanion",
        },
      }

      opts.extensions = opts.extensions or {}
      table.insert(opts.extensions, codecompanion)

      return opts
    end,
  },
  -- Which Key
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "AI Chat", icon = "󰚩" },
      },
    },
  },
  -- Markview
  {
    "OXY2DEV/markview.nvim",
    ft = function(_, ft)
      table.insert(ft, "codecompanion")

      return ft
    end,
    opts = function(_, opts)
      table.insert(opts.preview.filetypes, "codecompanion")

      local preview = {
        ignore_buftypes = {},
      }

      opts.preview = vim.tbl_deep_extend("keep", opts.preview, preview)
    end,
  },
}
