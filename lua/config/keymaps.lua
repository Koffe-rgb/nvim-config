vim.keymap.set(
    "n",
    "<Esc>",
    "<cmd>nohlsearch<CR>",
    { desc = "Clear highlights on search when pressing <Esc> in normal mode" }
)
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- disable arrows
vim.keymap.set({ "n", "i", "v" }, "<left>", "<Nop>")
vim.keymap.set({ "n", "i", "v" }, "<right>", "<Nop>")
vim.keymap.set({ "n", "i", "v" }, "<up>", "<Nop>")
vim.keymap.set({ "n", "i", "v" }, "<down>", "<Nop>")

-- build project with :make
vim.keymap.set("n", "<leader>bb", "<cmd>make<CR>", { desc = "Build project" })

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>", { desc = "Next item on quickfix list" })
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>", { desc = "Next item on quickfix list" })
