-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- golang Support
  use 'ray-x/go.nvim'
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- fuzzy finder
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- theme
  use 'rose-pine/neovim'

  -- treesitter
  use {
	  'nvim-treesitter/nvim-treesitter',
	  run = function()
		local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
		ts_update()
	  end,
  }

  -- directory tree
    use {
	  'nvim-tree/nvim-tree.lua',
	  requires = {
		  'nvim-tree/nvim-web-devicons', -- optional, for file icons
	  },
  }
  -- oil.nvim, because it's time to get more sophisticated
  use("stevearc/oil.nvim")

  -- undo tree
  use("mbbill/undotree")
  use("tpope/vim-fugitive")

  -- language server
  use('neovim/nvim-lspconfig')
  use('williamboman/mason.nvim')
  use('williamboman/mason-lspconfig.nvim')
  -- Autocompletion
  use('hrsh7th/nvim-cmp')
  use('hrsh7th/cmp-nvim-lsp')
  -- Snippets
  use('L3MON4D3/LuaSnip')
  -- nvim v0.7.2
  use({
      "kdheepak/lazygit.nvim",
      -- optional for floating window border decoration
      requires = {
          "nvim-lua/plenary.nvim",
      },
  })
  -- markdown viewer 
  use({
      'MeanderingProgrammer/render-markdown.nvim',
  })

  -- status bar
  use {
     'nvim-lualine/lualine.nvim',
     requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
  use {'akinsho/bufferline.nvim', tag = "*", requires = 'nvim-tree/nvim-web-devicons'}


  -- gitsigns 
  use { 'lewis6991/gitsigns.nvim' }


  -- debugger 
  use 'mfussenegger/nvim-dap'
  use 'leoluz/nvim-dap-go'
  use { "nvim-neotest/nvim-nio" }
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }

  -- sql
  use 'tpope/vim-dadbod'
  use 'kristijanhusak/vim-dadbod-ui'
  use 'kristijanhusak/vim-dadbod-completion'

  -- notifications
  use 'rcarriga/nvim-notify'
end)
