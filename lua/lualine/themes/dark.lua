local c = require('dark.colors')
local cfg = vim.g.dark_config
local colors = {
    bg = c.bg0, -- Pure black
    fg = c.fg, -- Light gray from theme.json
    red = c.red, -- Error red from theme.json
    green = c.dark_cyan, -- Success green
    yellow = c.yellow, -- Warning yellow from theme.json
    blue = c.blue, -- Info blue from theme.json
    purple = c.purple, -- Purple from theme.json
    cyan = c.cyan, -- Cyan from theme.json
    gray = c.grey -- Comment gray from theme.json
}

local one_dark = {
    inactive = {
        a = {fg = colors.gray, bg = colors.bg, gui = 'bold'},
        b = {fg = colors.gray, bg = colors.bg},
        c = {fg = colors.gray, bg = cfg.lualine.transparent and c.none or c.bg1},
    },
    normal = {
        a = {fg = colors.bg, bg = colors.green, gui = 'bold'}, -- Green for normal mode
        b = {fg = colors.fg, bg = c.bg2}, -- Slightly lighter bg
        c = {fg = colors.fg, bg = cfg.lualine.transparent and c.none or c.bg1},
    },
    visual = {a = {fg = colors.bg, bg = colors.purple, gui = 'bold'}}, -- Purple for visual
    replace = {a = {fg = colors.bg, bg = colors.red, gui = 'bold'}}, -- Red for replace
    insert = {a = {fg = colors.bg, bg = colors.blue, gui = 'bold'}}, -- Blue for insert
    command = {a = {fg = colors.bg, bg = colors.yellow, gui = 'bold'}}, -- Yellow for command
    terminal = {a = {fg = colors.bg, bg = colors.cyan, gui = 'bold'}}, -- Cyan for terminal
}
return one_dark;