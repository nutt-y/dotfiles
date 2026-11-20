if true then
  return {}
end

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
    config = function(_, opts)
      require("codecompanion").setup(opts)

      -- Connect to opencode when a chat opens, but only create the session on the first
      -- message, so empty chats never end up in opencode's session history
      local helper_utils = require("codecompanion.interactions.chat.helpers")

      ---@diagnostic disable-next-line: duplicate-set-field
      helper_utils.create_acp_connection = function(chat, cb)
        require("codecompanion.utils.async").sync(function()
          local ACPHandler = require("codecompanion.interactions.chat.acp.handler")
          ACPHandler.new(chat):ensure_connection()
          if cb then
            vim.schedule(cb)
          end
        end)()
      end

      -- Closing a chat also deletes its opencode session, so closed chats don't stay on disk
      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanionChatClosed",
        group = vim.api.nvim_create_augroup("nutt.codecompanion.delete_session", { clear = true }),
        callback = function(ev)
          local chat = require("codecompanion").buf_get_chat(ev.data.bufnr)
          local session_id = chat and chat.acp_connection and chat.acp_connection.session_id
          if not session_id then
            return -- nothing was ever sent, so no session exists
          end

          vim.system({ "opencode", "session", "delete", session_id }, { text = true }, function(result)
            if result.code ~= 0 then
              vim.schedule(function()
                vim.notify(
                  ("Failed to delete opencode session %s:\n%s"):format(session_id, result.stderr or ""),
                  vim.log.levels.WARN
                )
              end)
            end
          end)
        end,
      })
    end,
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
                n = "<leader>ai",
              },
              description = "Change adapter and model",
            },
            next_chat = {
              modes = {
                n = "<leader>a}",
              },
              description = "Open the next chat",
            },
            previous_chat = {
              modes = {
                n = "<leader>a{",
              },
              description = "Open the previous chat",
            },
          },
          slash_commands = {
            -- The built-in `/skills` is HTTP-only, so this picker hands the chosen skill to opencode.
            -- opencode resolves skills by their directory name, not the frontmatter `name`, so that's the ID we send
            skill = {
              description = "Pick a skill for opencode to use",
              ---@param chat CodeCompanion.Chat
              callback = function(chat)
                local files = require("codecompanion.utils.files")
                local picker = require("codecompanion.providers.slash_commands.picker")

                -- Later dirs take precedence, so a project skill overrides a personal one with the same ID
                local skill_dirs = { "~/.config/.agents/skills", "~/.agents/skills", ".agents/skills" }

                ---Pull a single-line value out of a SKILL.md's frontmatter
                ---@param path string
                ---@param key string
                ---@return string|nil
                local function frontmatter_value(path, key)
                  local ok, lines = pcall(vim.fn.readfile, path, "", 30)
                  if not ok or lines[1] ~= "---" then
                    return nil
                  end
                  for i = 2, #lines do
                    if lines[i] == "---" then
                      return nil
                    end
                    local value = lines[i]:match("^" .. key .. ":%s*(.-)%s*$")
                    if value then
                      return (value:gsub("^[\"'](.*)[\"']$", "%1"))
                    end
                  end
                end

                ---@return CodeCompanion.SlashCommand.PickerItem[]
                local function list_skills()
                  local by_id = {}
                  for _, configured in ipairs(skill_dirs) do
                    local dir = vim.fs.abspath(vim.fs.normalize(configured))
                    if vim.fn.isdirectory(dir) == 1 then
                      local scan_opts = { patterns = "SKILL.md", max_depth = 5, follow = true, skip_hidden = true }
                      for _, path in ipairs(files.scan_dir(dir, scan_opts)) do
                        local id = vim.fs.basename(vim.fs.dirname(path))
                        by_id[id] = {
                          name = id,
                          description = frontmatter_value(path, "description") or "",
                          path = path,
                        }
                      end
                    end
                  end

                  local skills = vim.tbl_values(by_id)
                  table.sort(skills, function(a, b)
                    return a.name < b.name
                  end)
                  return skills
                end

                -- A minimal slash command object, so the built-in pickers (and their previews) can drive it
                local slash_command = {
                  Chat = chat,
                  config = { opts = { provider = require("codecompanion.providers").pickers } },
                }

                ---Attach the skill to the next message, which is when opencode sees it
                ---@param selected CodeCompanion.SlashCommand.PickerItem
                function slash_command:output(selected)
                  if not selected then
                    return
                  end

                  local id = "<skill>" .. selected.name .. "</skill>"
                  if require("codecompanion.interactions.chat.helpers").has_context(id, self.Chat.messages) then
                    return
                  end

                  self.Chat:add_context({
                    role = "user",
                    content = ("Use the `%s` skill for this request: load it with the skill tool and follow its instructions."):format(
                      selected.name
                    ),
                  }, { source = "skill", id = id, path = selected.path })
                end

                local providers = picker.build_list_pickers({
                  prompt = "Select a skill",
                  empty_message = "No skills found",
                  preview = true,
                  items = list_skills,
                })

                require("codecompanion.interactions.chat.slash_commands").new():set_provider(slash_command, providers)
              end,
              opts = {
                contains_code = false,
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
                  model = "claude-agent/opus",
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
          input = {
            layout = "split",
            height = 10,
          },
          window = {
            layout = "vertical",
            position = "right",
          },
          intro_message = "Start The Chat! Press ? for options",
          show_settings = false,
          show_token_count = true,
          show_context = true,
          show_reasoning = false,
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
        desc = "Toggle Chat Buffer",
      },
      {
        "<leader>an",
        mode = { "n" },
        function()
          require("codecompanion").chat()
        end,
        desc = "Open a new chat",
      },
      {
        "<leader>al",
        mode = { "n" },
        function()
          local cc = require("codecompanion")
          local config = require("codecompanion.config")
          local slash_commands = require("codecompanion.interactions.chat.slash_commands")

          local function resume(chat)
            slash_commands.run({
              label = "resume",
              config = config.interactions.chat.slash_commands.resume,
            }, chat)
          end

          -- Reuse the last chat if nothing has been sent in it yet
          local chat = cc.last_chat()
          if chat and chat.cycle <= 1 and chat.acp_connection and chat.acp_connection:is_ready() then
            if not chat.ui:is_visible() then
              chat.ui:open()
            end
            return resume(chat)
          end

          -- Otherwise open a fresh chat (this hides the current one) and resume once it's connected
          vim.api.nvim_create_autocmd("User", {
            pattern = "CodeCompanionACPConnected",
            once = true,
            callback = function(ev)
              vim.schedule(function()
                local new_chat = cc.buf_get_chat(ev.data.bufnr)
                if new_chat then
                  resume(new_chat)
                end
              end)
            end,
          })
          cc.chat()
        end,
        desc = "Switch opencode session",
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
      {
        "<leader>am",
        mode = { "n" },
        function()
          vim.system({ "opencode", "mcp", "list" }, { text = true }, function(result)
            -- Strip ANSI colour codes and trailing whitespace from the CLI output
            local output = (result.stdout or "") .. (result.stderr or "")
            output = output:gsub("\27%[[%d;]*%a", ""):gsub("%s+$", "")

            vim.schedule(function()
              vim.lsp.util.open_floating_preview(vim.split(output, "\n"), "text", {
                border = "rounded",
                title = " MCP Servers ",
                title_pos = "center",
                focus_id = "opencode_mcp_list",
              })
            end)
          end)
        end,
        desc = "List opencode MCP servers",
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
