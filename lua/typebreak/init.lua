local M = {}

local api = vim.api
local curl = require("plenary.curl")

M.buf = nil

function M.start()
    local width = 50
    local height = 11
    local ui = api.nvim_list_uis()[1]

    local response = curl.get("https://random-word-api.herokuapp.com/word?number=10")
    local body = response.body

    local lines = {}
    local words = {}

    local delimiter = ","
    for match in (body..delimiter):gmatch("(.-)"..delimiter) do
        match = string.gsub(match, '%W', '')
        table.insert(words, match)
    end

    for _, word in pairs(words) do
        local length = string.len(word)
        local before = math.random(0, width-length)
        local after = width - length - before
        table.insert(lines, string.rep(' ', before) .. word .. string.rep(' ', after))
    end

    local buf = api.nvim_create_buf(false, 0)

    M.buf = buf

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

    M.set_mapping()
end

function M.key_pressed(key)
    print('PRESSED KEY' .. key)
end

function M.set_mapping()
    local keys = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
    for _,letter in pairs(keys) do
        vim.api.nvim_buf_set_keymap(M.buf, 'n', letter, '<cmd>lua require("typebreak").key_pressed("' .. letter .. '")<CR>', {noremap = true, silent = true})
    end
end

return M
