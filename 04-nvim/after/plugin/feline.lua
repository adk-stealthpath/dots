vim.g.nord_contrast = false
vim.g.nord_borders = false
vim.g.nord_disable_background = true
vim.g.nord_italic = true 
vim.g.nord_bold = true 

cs = require('everforest')
cs.setup({
    transparent_background_level = 1
})
cs.load()

local theme = require("lualine.themes.everforest")
local modes = { "normal", "insert", "visual", "replace", "command", "inactive" }
for _, mode in ipairs(modes) do
  theme[mode].c.bg = "NONE"
end

require("lualine").setup({
  options = {
    theme = theme,
  },
})

require('bufferline').setup{
    options = {
        sort_by = "tabs",
        show_close_icons = false,
    }
}
