local opt = vim.opt
local g = vim.g

-- Cursor
local old_guicursor = vim.o.guicursor
vim.o.guicursor = old_guicursor .. ",n-v-c:block-blinkon700-blinkoff400,i-ci-ve:ver25-blinkon700-blinkoff400"

-- Setup The column
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

-- Sign Column
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ruler = false
vim.opt.sidescrolloff = 8

-- Fold
vim.opt.foldmethod = "indent"
vim.opt.foldtext = ""

-- Clipboard
vim.opt.clipboard:append(vim.env.SSH_TTY and "" or "unnamedplus") -- Sync with system clipboard
g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}

-- Editing
vim.opt.autowrite = true
vim.opt.expandtab = true -- Use spaces
vim.opt.jumpoptions = "view"
vim.opt.smartindent = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.wrap = false
vim.opt.undofile = true
vim.opt.tabstop = 2
vim.opt.timeoutlen = 500
vim.opt.smoothscroll = true
vim.opt.autoindent = true
vim.opt.confirm = true

-- Buffer
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
vim.opt.updatetime = 200
vim.opt.list = true -- Show some invisible characters
vim.opt.foldlevel = 99
vim.opt.scrolloff = 4
vim.opt.termguicolors = true
vim.opt.linebreak = true
vim.opt.spelllang = { "en" }
vim.opt.cursorline = false -- no cursorline

-- Search
vim.opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
vim.opt.formatoptions = "jcroqlnt" -- tcqj
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.ignorecase = true -- Ignore case
vim.opt.smartcase = true -- If included mized case is search, then search sensitive
vim.opt.inccommand = "nosplit" -- preview incremental substitute
vim.opt.jumpoptions = "view"

-- Status Column
vim.opt.splitright = true -- Put new windows right of current
vim.opt.laststatus = 3
vim.opt.showmode = false

-- Misc
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- Windows
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitkeep = "screen"
vim.opt.splitright = true -- Put new windows right of current

-- Copy/Paste
-- local paste = function()
--   return {
--     vim.fn.split(vim.fn.getreg(""), "\n"),
--     vim.fn.getregtype(""),
--   }
-- end

-- Clipboard
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--
--     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--     ["-"] = require("vim.ui.clipboard.osc52").copy("-"),
--   },
--   paste = {
--     ["+"] = paste,
--     ["-"] = paste,
--   },
-- }

-- Neovide
if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font Mono"

  vim.g.neovide_window_blurred = true
  vim.g.neovide_opacity = 0.5
  vim.g.neovide_show_border = true
  vim.g.neovide_normal_opacity = 0.8
end
