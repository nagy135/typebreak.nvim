local M = {}

local api = vim.api
local curl = require("plenary.curl")

M.buf = nil
M.memory = ""
M.words = {}
M.lines = {}
M.width = 50
M.height = 10

function M.start()
    local ui = api.nvim_list_uis()[1]

    -- reset
    M.lines = {}
    M.words = {}
    M.memory = ""

    local response = curl.get("https://random-word-api.herokuapp.com/word?number=10")
    local body = response.body

    local delimiter = ","
    for match in (body..delimiter):gmatch("(.-)"..delimiter) do
        match = string.gsub(match, '%W', '')
        table.insert(M.words, match)
    end

    for _, word in pairs(M.words) do
        local length = string.len(word)
        local before = math.random(0, M.width-length)
        local after = M.width - length - before
        table.insert(M.lines, string.rep(' ', before) .. word .. string.rep(' ', after))
    end

    local buf = api.nvim_create_buf(false, true)
    print("buf",vim.inspect(buf))

    M.buf = buf

    local opts = {
        relative = "editor",
        width = M.width,
        height = M.height,
        col = (ui.width/2) - (M.width/2),
        row = (ui.height/2) - (M.height/2),
        border = "shadow",
        anchor = 'NW',
        style = 'minimal',
    }
    M.draw()

    api.nvim_open_win(buf, 1, opts)

    M.set_mapping()
end

function M.draw()
    api.nvim_buf_set_lines(M.buf, 0, 10, false, M.lines)
end

function M.key_pressed(key)
    if key == "BS" then
        M.memory = string.sub(M.memory, 0, -2)
        print("memory",vim.inspect(M.memory))
        M.draw()
        return
    end
    M.memory = M.memory .. key
    print("memory",vim.inspect(M.memory))
    local match = false
    for k, word in pairs(M.words) do
        if string.sub(M.memory, -string.len(word)) == word then
            match = true
            M.lines[k] = string.rep(' ', M.width)
        end
    end
    if match == true then
        M.memory = ""
        M.draw()
    end
end

function M.set_mapping()
    local keys = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
    for _,letter in pairs(keys) do
        vim.api.nvim_buf_set_keymap(M.buf, 'i', letter, '<cmd>lua require("typebreak").key_pressed("' .. letter .. '")<CR>', {noremap = true, silent = true})
    end
    vim.api.nvim_buf_set_keymap(M.buf, 'i', '<BS>', '<CMD>lua require("typebreak").key_pressed("BS")<CR>', {noremap = true, silent = true})
end

return M
