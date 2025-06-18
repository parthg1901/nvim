return {
  "stevearc/resession.nvim",
  config = function()
    local resession = require("resession")

    resession.setup() -- no extensions

    -- Keymaps
    vim.keymap.set("n", "<leader>ss", function()
      resession.save(vim.fn.input("Save session as: "))
    end, { desc = "Session Save" })

    vim.keymap.set("n", "<leader>sl", function()
      resession.load(vim.fn.input("Load session: "))
    end, { desc = "Session Load" })

    vim.keymap.set("n", "<leader>sd", function()
      resession.delete(vim.fn.input("Delete session: "))
    end, { desc = "Session Delete" })
  end,
}
