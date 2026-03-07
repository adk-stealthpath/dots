return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()

      vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>')
    end,
  }
}
