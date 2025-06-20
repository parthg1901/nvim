local M = {}

local counter_file = vim.fn.stdpath("data") .. "/counter.txt"
M.value = 0

-- Load counter from file
function M.load()
  local f = io.open(counter_file, "r")
  if f then
    local num = tonumber(f:read("*l"))
    f:close()
    M.value = num or 0
  else
    M.value = 0
  end
end

-- Save counter to file
function M.save()
  local f = io.open(counter_file, "w")
  if f then
    f:write(tostring(M.value))
    f:close()
  end
end

function M.increment()
  M.value = M.value + 1
  M.save()
  require("lualine").refresh()
end

function M.decrement()
  M.value = M.value - 1
  M.save()
  require("lualine").refresh()
end

function M.reset()
  M.value = 0
  M.save()
  require("lualine").refresh()
end

function M.get()
  return tostring(M.value)
end

-- Auto-load on require
M.load()

return M
