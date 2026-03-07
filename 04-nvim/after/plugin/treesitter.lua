local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

parser_config.cypher = {
  install_info = {
    url = vim.fn.expand('~/.local/share/nvim/tree-sitter-cypher'),
    files = { "src/parser.c" },
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = "cypher",
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "rust", "go", "python", "typescript", "cypher" },
  sync_install = false,
  auto_install = true,

  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
}

vim.filetype.add({ extension = { cypher = "cypher", cql = "cypher" } })
