return {
  -- Conform
  {
    "stevearc/conform.nvim",
    opts = {
      -- Define your formatters
      formatters_by_ft = {
        markdown = { "markdownlint" },
      },
    },
  },
  -- Lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        harper_ls = {
          filetypes = { "markdown", "text" },
          settings = {
            ["harper-ls"] = {
              userDictPath = "",
              fileDictPath = "",
              linters = {
                SpellCheck = true,
                SpelledNumbers = false,
                AnA = true,
                SentenceCapitalization = true,
                UnclosedQuotes = true,
                WrongQuotes = false,
                LongSentences = true,
                RepeatedWords = true,
                Spaces = true,
                Matcher = true,
                CorrectNumberSuffix = true,
              },
              codeActions = {
                ForceStable = false,
              },
              markdown = {
                IgnoreLinkTitle = false,
              },
              diagnosticSeverity = "hint",
              isolateEnglish = false,
            },
          },
        },
        marksman = {},
      },
    },
  },
  -- Blink
  {
    "Saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          markdown = { "snippets", "path", "lsp" },
        },
      },
    },
  },
  -- Markview
  {
    "OXY2DEV/markview.nvim",
    lazy = true,
    ft = { "markdown" },
    keys = {
      {
        "<leader>uw",
        function()
          vim.wo.wrap = not vim.wo.wrap

          -- markview doesn't redraw on option changes, so tables stay stale otherwise
          local buf = vim.api.nvim_get_current_buf()
          if require("markview.state").buf_attached(buf) then
            require("markview.actions").render(buf)
          end
        end,
        desc = "Toggle line wrap",
      },
    },
    opts = {
      preview = {
        filetypes = { "markdown", "md" },
        icon_provider = "mini",
      },
    },
  },
}
