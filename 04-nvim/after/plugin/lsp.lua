-- note: diagnostics are not exclusive to lsp servers
-- so these can be global keybindings
vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
vim.keymap.set('n', 'dp', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
vim.keymap.set('n', 'dn', '<cmd>lua vim.diagnostic.goto_next()<cr>') 

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    -- these will be buffer-local keybindings
    -- because they only work if you have an active language server

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, 'gf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<leader>ga', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end
})

-- Filetype detection for templ
vim.filetype.add({
  extension = {
    templ = 'templ',
  },
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

local default_setup = function(server)
  require('lspconfig')[server].setup({
    capabilities = lsp_capabilities,
  })
end

-- LSP floating window borders (hover, signature help, diagnostics)
local border = {
  {"╭", "FloatBorder"},
  {"─", "FloatBorder"},
  {"╮", "FloatBorder"},
  {"│", "FloatBorder"},
  {"╯", "FloatBorder"},
  {"─", "FloatBorder"},
  {"╰", "FloatBorder"},
  {"│", "FloatBorder"},
}

-- Set border for LSP floating windows globally
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Set border for diagnostic floating windows
vim.diagnostic.config({
  float = {
    border = border,
  }
})

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'gopls',
    'pylsp',
  },
  handlers = {
    default_setup,
    gopls = function()
        require('lspconfig').gopls.setup({
            capabilities = lsp_capabilities,
            cmd = { '/home/akingston/go/bin/gopls' },
            single_file_support = true,
        })
    end,
    pylsp = function()
      require('lspconfig').pylsp.setup({
        capabilities = lsp_capabilities,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                enabled = true,
                ignore = {'E501'},  -- Ignore line too long
                maxLineLength = 120  -- Or whatever you want
              },
            }
          }
        }
      })
    end,
  },
})

-- templ LSP setup (manual, not managed by mason)
require('lspconfig').templ.setup({
  capabilities = lsp_capabilities,
  on_attach = function(client, bufnr)
    -- Format on save for templ files
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
})

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  window = {
    completion = cmp.config.window.bordered({
      winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
    }),
    documentation = cmp.config.window.bordered({
      winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
    }),
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({select = false}),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})

vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE' })
-- vim.api.nvim_set_hl(0, 'PmenuBorder', { fg = '#3e3e3e', bg = vim.api.nvim_get_hl(0, {name = 'Pmenu'}).bg })
vim.api.nvim_set_hl(0, 'PmenuBorder', { fg = '#3e3e3e', bg = '#1e1e1e' })  -- match your Pmenu bg color

