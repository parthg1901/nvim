-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local km = vim.keymap.set
km("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })
km("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })
km("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Show all todos (Telescope)" })
km("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "Show todos (Trouble)" })
