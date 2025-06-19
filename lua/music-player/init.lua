local M = {}

-- Configuration
M.config = {
  music_dir = vim.fn.expand("~/Music/nvim"),
  volume = 100,
  supported_formats = { "mp3", "mp4", "wav", "flac", "ogg", "m4a" },
  player_cmd = "mpv", -- Change to "ffplay" if you prefer
}

-- State
M.state = {
  current_song = nil,
  current_index = 1,
  playlist = {},
  is_playing = false,
  is_paused = false,
  job_id = nil,
  volume = 100,
}

-- Utility functions
local function notify(msg, level)
  vim.notify("[Music Player] " .. msg, level or vim.log.levels.INFO)
end

local function get_song_files()
  local files = {}
  local handle = io.popen('find "' .. M.config.music_dir .. '" -type f 2>/dev/null')

  if not handle then
    notify("Could not access music directory: " .. M.config.music_dir, vim.log.levels.ERROR)
    return files
  end

  for file in handle:lines() do
    local ext = file:match("%.([^%.]+)$")
    if ext then
      ext = ext:lower()
      for _, format in ipairs(M.config.supported_formats) do
        if ext == format then
          table.insert(files, file)
          break
        end
      end
    end
  end

  handle:close()
  return files
end

local function get_song_name(filepath)
  local name = filepath:match("([^/]+)$") -- Get filename
  return name:gsub("%.[^%.]+$", "") -- Remove extension
end

local function stop_current_player()
  if M.state.job_id then
    vim.fn.jobstop(M.state.job_id)
    M.state.job_id = nil
  end
  M.state.is_playing = false
  M.state.is_paused = false
end

-- Core functions
function M.refresh_playlist()
  M.state.playlist = get_song_files()
  if #M.state.playlist == 0 then
    notify("No music files found in " .. M.config.music_dir, vim.log.levels.WARN)
    return false
  end

  -- Sort playlist alphabetically
  table.sort(M.state.playlist, function(a, b)
    return get_song_name(a):lower() < get_song_name(b):lower()
  end)

  return true
end

function M.get_now_playing()
  if not M.state.current_song or not M.state.is_playing then
    return ""
  end
  return "🎧 " .. get_song_name(M.state.current_song)
end

function M.play_song(index)
  if not M.refresh_playlist() then
    return
  end

  index = index or M.state.current_index
  if index < 1 or index > #M.state.playlist then
    notify("Invalid song index", vim.log.levels.ERROR)
    return
  end

  stop_current_player()

  local song = M.state.playlist[index]
  M.state.current_song = song
  M.state.current_index = index

  -- Build command based on available player
  local cmd
  if vim.fn.executable("mpv") == 1 then
    cmd = {
      "mpv",
      "--no-video",
      "--volume=" .. M.state.volume,
      "--really-quiet",
      song,
    }
  elseif vim.fn.executable("ffplay") == 1 then
    cmd = {
      "ffplay",
      "-nodisp",
      "-autoexit",
      "-volume",
      tostring(M.state.volume),
      "-loglevel",
      "quiet",
      song,
    }
  else
    notify("No supported audio player found (mpv or ffplay)", vim.log.levels.ERROR)
    return
  end

  M.state.job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 and M.state.is_playing then
        -- Song finished naturally, play next
        M.next_song()
      else
        M.state.is_playing = false
        M.state.is_paused = false
        M.state.job_id = nil
      end
    end,
  })

  if M.state.job_id > 0 then
    M.state.is_playing = true
    M.state.is_paused = false
    notify("♪ Playing: " .. get_song_name(song))
  else
    notify("Failed to start music player", vim.log.levels.ERROR)
  end
end

function M.pause()
  if not M.state.is_playing then
    notify("No music is currently playing", vim.log.levels.WARN)
    return
  end

  if M.state.is_paused then
    notify("Music is already paused", vim.log.levels.WARN)
    return
  end

  -- Send pause signal (works with mpv)
  if M.state.job_id then
    vim.fn.chansend(M.state.job_id, "p")
    M.state.is_paused = true
    notify("⏸ Paused: " .. get_song_name(M.state.current_song))
  end
end

function M.resume()
  if not M.state.is_playing then
    notify("No music is currently playing", vim.log.levels.WARN)
    return
  end

  if not M.state.is_paused then
    notify("Music is not paused", vim.log.levels.WARN)
    return
  end

  -- Send resume signal (works with mpv)
  if M.state.job_id then
    vim.fn.chansend(M.state.job_id, "p")
    M.state.is_paused = false
    notify("▶ Resumed: " .. get_song_name(M.state.current_song))
  end
end

function M.stop()
  if not M.state.is_playing then
    notify("No music is currently playing", vim.log.levels.WARN)
    return
  end

  stop_current_player()
  notify("⏹ Stopped")
end

function M.next_song()
  if #M.state.playlist == 0 then
    notify("No songs in playlist", vim.log.levels.WARN)
    return
  end

  local next_index = M.state.current_index + 1
  if next_index > #M.state.playlist then
    next_index = 1 -- Loop back to first song
  end

  M.play_song(next_index)
end

function M.prev_song()
  if #M.state.playlist == 0 then
    notify("No songs in playlist", vim.log.levels.WARN)
    return
  end

  local prev_index = M.state.current_index - 1
  if prev_index < 1 then
    prev_index = #M.state.playlist -- Loop to last song
  end

  M.play_song(prev_index)
end

function M.volume_up()
  M.state.volume = math.min(100, M.state.volume + 10)

  if M.state.is_playing and M.state.job_id then
    -- Send volume command to mpv
    vim.fn.chansend(M.state.job_id, "0")
  end

  notify("🔊 Volume: " .. M.state.volume .. "%")
end

function M.volume_down()
  M.state.volume = math.max(0, M.state.volume - 10)

  if M.state.is_playing and M.state.job_id then
    -- Send volume command to mpv
    vim.fn.chansend(M.state.job_id, "9")
  end

  notify("🔉 Volume: " .. M.state.volume .. "%")
end

function M.list_songs()
  if not M.refresh_playlist() then
    return
  end

  local lines = { "🎵 Music Playlist:" }
  for i, song in ipairs(M.state.playlist) do
    local marker = (i == M.state.current_index and M.state.is_playing) and "▶ " or "  "
    table.insert(lines, string.format("%s%d. %s", marker, i, get_song_name(song)))
  end

  -- Create a floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "musicplaylist")

  local width = 60
  local height = math.min(#lines + 2, 20)
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " Music Player ",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Set up keymaps for the playlist window
  local function close_window()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
    callback = close_window,
    desc = "Close playlist",
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
    callback = close_window,
    desc = "Close playlist",
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    callback = function()
      local line = vim.api.nvim_win_get_cursor(win)[1]
      if line > 1 and line <= #M.state.playlist + 1 then
        local song_index = line - 1
        close_window()
        M.play_song(song_index)
      end
    end,
    desc = "Play selected song",
  })
end

function M.current_info()
  if not M.state.current_song then
    notify("No song currently loaded", vim.log.levels.WARN)
    return
  end

  local status = M.state.is_playing and (M.state.is_paused and "⏸ Paused" or "▶ Playing") or "⏹ Stopped"
  local info = string.format(
    "%s\n🎵 %s\n🔊 Volume: %d%%\n📂 %d/%d songs",
    status,
    get_song_name(M.state.current_song),
    M.state.volume,
    M.state.current_index,
    #M.state.playlist
  )

  notify(info)
end

-- Command handlers
function M.handle_play()
  if M.state.is_paused then
    M.resume()
  else
    M.play_song()
  end
end

function M.handle_pause()
  if not M.state.is_paused then
    M.pause()
  else
    M.resume()
  end
end

-- Setup function
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)
  M.state.volume = M.config.volume

  -- Create music directory if it doesn't exist
  vim.fn.mkdir(M.config.music_dir, "p")

  -- Create commands
  vim.api.nvim_create_user_command("MusicPlay", M.handle_play, {})
  vim.api.nvim_create_user_command("MusicPause", M.handle_pause, {})
  vim.api.nvim_create_user_command("MusicStop", M.stop, {})
  vim.api.nvim_create_user_command("MusicNext", M.next_song, {})
  vim.api.nvim_create_user_command("MusicPrev", M.prev_song, {})
  vim.api.nvim_create_user_command("MusicList", M.list_songs, {})
  vim.api.nvim_create_user_command("MusicVolumeUp", M.volume_up, {})
  vim.api.nvim_create_user_command("MusicVolumeDown", M.volume_down, {})
  vim.api.nvim_create_user_command("MusicInfo", M.current_info, {})

  notify("Music Player loaded! Put your songs in " .. M.config.music_dir)
end

return M
