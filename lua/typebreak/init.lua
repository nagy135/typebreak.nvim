local M = {}

local api = vim.api
local curl = require("plenary.curl")

function M.start()
    local width = 50
    local height = 11
    local ui = api.nvim_list_uis()[1]

    local response = curl.get("https://random-word-api.herokuapp.com/word?number=10")
    -- if response.status ~= 200 then
    --     print('non-200 response from api')
    --     return
    -- end
    local body = response.body

    local lines = {}
    local words = {}

    local delimiter = ","
    for match in (body..delimiter):gmatch("(.-)"..delimiter) do
        match = string.gsub(match, '%W', '')
        table.insert(words, match)
    end

    for k, word in pairs(words) do
        print(string.len(word))
    end

    local buf = api.nvim_create_buf(false, 0)

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        col = (ui.width/2) - (width/2),
        row = (ui.height/2) - (height/2),
        border = "shadow",
        anchor = 'NW',
        style = 'minimal',
    }
    api.nvim_buf_set_lines(buf, 0, 0, true, lines)

    local win = api.nvim_open_win(buf, 1, opts)

    api.nvim_buf_set_keymap(buf, 'n', 's', '<cmd>lua print("pressed s")<CR>', {noremap = true, silent = true})
end


M.start()

return M
