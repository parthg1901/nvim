-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.opt.clipboard = "unnamedplus"
vim.g.python3_host_prog = "~/.venvs/nvim/bin/python"
vim.schedule(function()
  vim.ui.input = require("snacks.input").input
  vim.ui.select = require("snacks.picker").select
end)
vim.opt.swapfile = false

