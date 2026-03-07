return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Register custom cypher parser
      local parsers = require('nvim-treesitter.parsers')
      parsers.cypher = {
        install_info = {
          url = vim.fn.expand('~/.local/share/nvim/tree-sitter-cypher'),
          files = { "src/parser.c" },
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = "cypher",
      }

      require('nvim-treesitter').setup()

      -- Install parsers
      require('nvim-treesitter.install').install({
        'c', 'lua', 'rust', 'go', 'python', 'typescript', 'cypher'
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
