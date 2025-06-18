for k in pairs(package.loaded) do
    if k:match(".*dark.*") then package.loaded[k] = nil end
end

require('dark').setup()
require('dark').colorscheme()