return {
  "music-player.nvim",
  dir = vim.fn.stdpath("config") .. "/lua/music-player",
  keys = {
    { "<leader>mp", "<cmd>MusicPlay<cr>", desc = "Play music" },
    { "<leader>mP", "<cmd>MusicPause<cr>", desc = "Pause music" },
    { "<leader>mn", "<cmd>MusicNext<cr>", desc = "Next song" },
    { "<leader>mb", "<cmd>MusicPrev<cr>", desc = "Previous song" },
    { "<leader>ms", "<cmd>MusicStop<cr>", desc = "Stop music" },
    { "<leader>ml", "<cmd>MusicList<cr>", desc = "List songs" },
    { "<leader>m+", "<cmd>MusicVolumeUp<cr>", desc = "Volume up" },
    { "<leader>m-", "<cmd>MusicVolumeDown<cr>", desc = "Volume down" },
    { "<leader>mi", "<cmd>MusicInfo<cr>", desc = "Current song info" },
  },
  config = function()
    require("music-player").setup()
  end,
}
