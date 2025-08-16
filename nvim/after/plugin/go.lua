local go = require('go')
-- Run gofmt + goimport on save

local format_sync_grp = vim.api.nvim_create_augroup("goimports", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
   require('go.format').goimports()
  end,
  group = format_sync_grp,
})

vim.keymap.set("n", "<leader>gs", ":GoFillStruct<CR>")
vim.keymap.set("n", "<leader>ge", ":GoIfErr<CR>")
vim.keymap.set("n", "<leader>gt", ":GoTest")
vim.keymap.set("n", "<leader>gtp", ":GoTest -p")
vim.keymap.set("n", "<leader>gtf", ":GoTestFunc<CR>")
vim.keymap.set("n", "<leader>gc", ":GoCoverage<CR>")
vim.keymap.set("n", "<leader>gcp", ":GoCoverage -p")
vim.keymap.set("n", "<leader>gd", ":GoDoc<CR>")
vim.keymap.set("n", "<leader>gj", ":GoAddTag json<CR>")
vim.keymap.set("n", "<leader>gtf", ":GoTestFunc<CR>")
vim.keymap.set("n", "<leader>gb", ":! mage<CR>")


go.setup({
    tag_transform = "camelcase",
    tag_options = "json=omitempty",
})
