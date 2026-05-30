return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter').setup()

      -- Install parsers
      require('nvim-treesitter.install').install({
        'c', 'lua', 'rust', 'go', 'python', 'typescript', 'cypher', 'templ'
      })

      -- Enable highlighting via autocmd with filesize guard
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local max_filesize = 100 * 1024
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
          if ok and stats and stats.size > max_filesize then
            return
          end
          pcall(vim.treesitter.start)
        end,
      })

      vim.filetype.add({ extension = { cypher = "cypher", cql = "cypher" } })
    end,
  }
}
