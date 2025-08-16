vim.keymap.set("n", "<C-n>", vim.cmd.NvimTreeToggle)

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
local function attach(bufnr)
    local api = require('nvim-tree.api')
    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)
    
    vim.keymap.set('n', 's',   api.node.open.vertical,              opts('Open: Vertical Split'))
    vim.keymap.set('n', 'i',   api.node.open.horizontal,            opts('Open: Horizontal Split'))
end


require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
  },
  on_attach = attach,
})

