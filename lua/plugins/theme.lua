return {
  dir = "~/.config/nvim/colors",
  name = "dark",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd("colorscheme dark")
  end,
}