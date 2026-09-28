if true then
  return {}
end

---@module "lazy"
---@type LazySpec
return {
  {
    "amansingh-afk/milli.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      screensaver = {
        splash = "robot",
        after = 300, -- 5 minutes
        loop = true,
      },
    },
  },
}
