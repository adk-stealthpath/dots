vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "jk", "<Esc>")

-- move panes 
vim.keymap.set("n", "<leader>j", "<C-w><C-j>")
vim.keymap.set("n", "<leader>k", "<C-w><C-k>")
vim.keymap.set("n", "<leader>h", "<C-w><C-h>")
vim.keymap.set("n", "<leader>l", "<C-w><C-l>")

-- move tabs
vim.keymap.set("n", "<C-Left>", ":tabprevious<CR>")
vim.keymap.set("n", "<C-Right>", ":tabnext<CR>")


vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
         if #vim.v.argv == 2 then
 	    	vim.cmd("Telescope find_files")
         end
	end,
})
