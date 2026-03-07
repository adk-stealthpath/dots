return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.1",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ["<Esc>"] = require('telescope.actions').close,
            },
          },
        },
      })

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>tf', builtin.find_files, {})
      vim.keymap.set('n', '<leader>ts', builtin.lsp_document_symbols, {})
      vim.keymap.set('n', '<leader>td', builtin.diagnostics, {})
      vim.keymap.set('n', '<leader>ti', builtin.lsp_implementations, {})
      vim.keymap.set('n', '<leader>tg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>tb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>tj', builtin.jumplist, {})
    end,
  }
}

