local M = {}

local api = vim.api
local curl = require("plenary.curl")

M.buf = nil
M.memory = ""
M.words = {}
M.found = 0
M.lines = {}
M.width = 50
M.height = 10
M.timestamp = nil

function M.start()
    local ui = api.nvim_list_uis()[1]

    M.fetch_new_lines()

    M.buf = api.nvim_create_buf(false, true)

    M.draw()

    local opts = {
        relative = "editor",
        width = M.width,
        height = M.height,
        col = (ui.width / 2) - (M.width / 2),
        row = (ui.height / 2) - (M.height / 2),
        border = "shadow",
        anchor = 'NW',
        style = 'minimal',
    }

    api.nvim_open_win(M.buf, true, opts)

    M.set_mapping()
    M.timestamp = os.time()
    vim.cmd("startinsert")
end

function M.fetch_new_lines()
    -- reset
    M.lines = {}
    M.words = {}
    M.memory = ""

    local response = curl.get("https://random-word-api.herokuapp.com/word?number=10")
    if response == nil then
        print('could not fetch words from herokuapp.com')
        return
    end
    local body = response.body

    local delimiter = ","
    for match in (body .. delimiter):gmatch("(.-)" .. delimiter) do
        match = string.gsub(match, '%W', '')
        table.insert(M.words, match)
    end

    for _, word in pairs(M.words) do
        local length = string.len(word)
        local before = math.random(0, M.width - length)
        local after = M.width - length - before
        table.insert(M.lines, string.rep(' ', before) .. word .. string.rep(' ', after))
    end

end

function M.draw()
    api.nvim_buf_set_lines(M.buf, 0, 10, false, M.lines)
end

function M.set_centered_text(text, text2)
    local spacer = string.rep(' ', M.width / 2 - string.len(text) / 2)
    local spacedText = spacer .. text

    local spacedText2 = ""
    if text2 ~= nil then
        local spacer2 = string.rep(' ', M.width / 2 - string.len(text2) / 2)
        spacedText2 = spacer2 .. text2
    end

    M.lines = {
        "",
        "",
        "",
        spacedText,
        "",
        spacedText2,
        "",
        "",
        "",
        ""
    }

    M.draw()
end

function M.key_pressed(key)
    if key == "<BS>" then -- BACKSPACE
        M.memory = string.sub(M.memory, 0, -2)
        M.draw()
        return
    elseif key == "<CR>" then -- RESET
        api.nvim_buf_set_lines(M.buf, 0, 10, false, M.lines)
        M.timestamp = os.time()

        M.found = 0
        M.fetch_new_lines()
        M.draw()
        return
    end

    M.memory = M.memory .. key
    local match = false
    for k, word in pairs(M.words) do
        if string.sub(M.memory, -string.len(word)) == word then
            match = true
            M.found = M.found + 1
            M.lines[k] = string.rep(' ', M.width)
        end
    end
    if match == true then
        M.memory = ""
        M.draw()
    end

    if M.found == M.height then
        local timeString = string.format("Done in : %.2f", os.time() - M.timestamp)
        M.set_centered_text(timeString, "To refresh press <CR> (Enter)")
    end
end

function M.set_mapping()
    local keys = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
        "u", "v", "w", "x", "y", "z", "<BS>", "<CR>" }
    for _, letter in pairs(keys) do
        vim.keymap.set("i", letter, function() M.key_pressed(letter) end, {
            buffer = 0
        })
    end
end

return M
