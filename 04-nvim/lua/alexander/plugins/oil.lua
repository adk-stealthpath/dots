return {
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
          view_options = {
              show_hidden = true,
              is_hidden_file = function(name, buffnr)
                  local m = name:match("^%.")
                  return m ~= nil
              end,
              is_always_hidden = function(name, buffnr)
                  return false
              end
          },
          -- select which information to show. start with all and widdle down
          columns = {
              "icon",
              "permissions",
              "size",
              "mtime",
          },
      })
    end,
  }
}
