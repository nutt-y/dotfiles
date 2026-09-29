-- vim-herdr-navigation — Neovim side

---@module "lazy"
---@type LazySpec
return {
  "christoomey/vim-tmux-navigator", -- Tmux & split window navigation
  cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", mode = { "n" } },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", mode = { "n" } },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", mode = { "n" } },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", mode = { "n" } },
  },
}
