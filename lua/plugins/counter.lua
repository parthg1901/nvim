return {
  "counter.nvim",
  dir = vim.fn.stdpath("config") .. "/lua/plugins", -- adjust if needed
  keys = {
    {
      "<leader>ci",
      function()
        require("counter").increment()
      end,
      desc = "Counter Increment",
    },
    {
      "<leader>cd",
      function()
        require("counter").decrement()
      end,
      desc = "Counter Decrement",
    },
    {
      "<leader>cr",
      function()
        require("counter").reset()
      end,
      desc = "Counter Reset",
    },
  },
  config = function()
    -- Already auto-loaded in the module
  end,
}
