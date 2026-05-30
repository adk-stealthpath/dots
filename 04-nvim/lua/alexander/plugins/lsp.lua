return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
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

          vim.keymap.set('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
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

      require('mason').setup({})

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

      local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

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

      require('mason-lspconfig').setup({
        ensure_installed = { 'gopls', 'pylsp', 'lua_ls', 'templ' },
      })

      vim.lsp.config("gopls", {
        capabilities = lsp_capabilities,
        settings = {
          gopls = {
            gofumpt = true,
            analyses = { unusedparams = true },
          },
        },
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" } },
                apply = true,
                filter = function(action)
                    return action.title == "Organize Imports"
                end,
              })
              vim.lsp.buf.format({ async = false })
            end,
          })
        end,
      })
      vim.lsp.enable("gopls")

      vim.lsp.config("pylsp", {
        capabilities = lsp_capabilities,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                enabled = true,
                ignore = { 'E501' },
                maxLineLength = 120,
              },
            },
          },
        },
      })
      vim.lsp.enable("pylsp")

      vim.lsp.config("templ", {
        capabilities = lsp_capabilities,
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end,
      })
      vim.lsp.enable("templ")

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',  -- Neovim embeds LuaJIT
            },
            diagnostics = {
              globals = { 'vim' },
            },
            workspace = {
              library = {
                vim.env.VIMRUNTIME,           -- $VIMRUNTIME/lua — core API
                vim.fn.expand('~/dots/04-nvim'),     -- your own config dir
                -- For plugin dev, add the plugin root explicitly:
                vim.fn.expand('~/stealthpath/conduit.nvim'),
              },
              checkThirdParty = false,        -- suppress "Do you need to configure..." prompts
            },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.enable('lua_ls')

      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE' })
      -- vim.api.nvim_set_hl(0, 'PmenuBorder', { fg = '#3e3e3e', bg = vim.api.nvim_get_hl(0, {name = 'Pmenu'}).bg })
      vim.api.nvim_set_hl(0, 'PmenuBorder', { fg = '#3e3e3e', bg = '#1e1e1e' })  -- match your Pmenu bg color
    end,
  }
}
