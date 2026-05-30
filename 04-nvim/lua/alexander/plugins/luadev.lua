-- lua/alexander/plugins/lazydev.lua
return {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
        library = {
            { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
    },
}

